(function() {
  const THREE = window.THREE;

  const _changeEvent = { type: 'change' };
  const _startEvent = { type: 'start' };
  const _endEvent = { type: 'end' };
  const _ray = new THREE.Ray();
  const _plane = new THREE.Plane();
  const _TILT_LIMIT = Math.cos(70 * THREE.MathUtils.DEG2RAD);
  const _v = new THREE.Vector3();
  const _twoPI = 2 * Math.PI;

  const _STATE = {
    NONE: -1,
    ROTATE: 0,
    DOLLY: 1,
    PAN: 2,
    TOUCH_ROTATE: 3,
    TOUCH_PAN: 4,
    TOUCH_DOLLY_PAN: 5,
    TOUCH_DOLLY_ROTATE: 6
  };
  const _EPS = 0.000001;

  class OrbitControls extends THREE.EventDispatcher {
    constructor(object, domElement) {
      super();

      this.object = object;
      this.domElement = domElement;
      this.domElement.style.touchAction = 'none';

      this.enabled = true;
      this.target = new THREE.Vector3();

      this.minDistance = 0;
      this.maxDistance = Infinity;

      this.minZoom = 0;
      this.maxZoom = Infinity;

      this.minPolarAngle = 0;
      this.maxPolarAngle = Math.PI;

      this.minAzimuthAngle = -Infinity;
      this.maxAzimuthAngle = Infinity;

      this.enableDamping = false;
      this.dampingFactor = 0.05;

      this.enableZoom = true;
      this.zoomSpeed = 1.0;

      this.enableRotate = true;
      this.rotateSpeed = 1.0;

      this.enablePan = true;
      this.panSpeed = 1.0;
      this.screenSpacePanning = true;
      this.keyPanSpeed = 7.0;

      this.autoRotate = false;
      this.autoRotateSpeed = 2.0;

      this.keys = { LEFT: 'ArrowLeft', UP: 'ArrowUp', RIGHT: 'ArrowRight', BOTTOM: 'ArrowDown' };
      this.mouseButtons = { LEFT: THREE.MOUSE.ROTATE, MIDDLE: THREE.MOUSE.DOLLY, RIGHT: THREE.MOUSE.PAN };
      this.touches = { ONE: THREE.TOUCH.ROTATE, TWO: THREE.TOUCH.DOLLY_PAN };

      this.target0 = this.target.clone();
      this.position0 = this.object.position.clone();
      this.zoom0 = this.object.zoom;

      this._domElementKeyEvents = null;

      const scope = this;
      const state = { current: _STATE.NONE };

      const spherical = new THREE.Spherical();
      const sphericalDelta = new THREE.Spherical();

      let scale = 1;
      const panOffset = new THREE.Vector3();

      const rotateStart = new THREE.Vector2();
      const rotateEnd = new THREE.Vector2();
      const rotateDelta = new THREE.Vector2();

      const panStart = new THREE.Vector2();
      const panEnd = new THREE.Vector2();
      const panDelta = new THREE.Vector2();

      const dollyStart = new THREE.Vector2();
      const dollyEnd = new THREE.Vector2();
      const dollyDelta = new THREE.Vector2();

      const pointers = [];
      const pointerPositions = {};

      function getAutoRotationAngle() {
        return 2 * Math.PI / 60 / 60 * scope.autoRotateSpeed;
      }

      function getZoomScale() {
        return Math.pow(0.95, scope.zoomSpeed);
      }

      function rotateLeft(angle) {
        sphericalDelta.theta -= angle;
      }

      function rotateUp(angle) {
        sphericalDelta.phi -= angle;
      }

      const panLeft = (function() {
        const v = new THREE.Vector3();
        return function panLeft(distance, objectMatrix) {
          v.setFromMatrixColumn(objectMatrix, 0);
          v.multiplyScalar(-distance);
          panOffset.add(v);
        };
      })();

      const panUp = (function() {
        const v = new THREE.Vector3();
        return function panUp(distance, objectMatrix) {
          if (scope.screenSpacePanning === true) {
            v.setFromMatrixColumn(objectMatrix, 1);
          } else {
            v.setFromMatrixColumn(objectMatrix, 0);
            v.crossVectors(scope.object.up, v);
          }
          v.multiplyScalar(distance);
          panOffset.add(v);
        };
      })();

      const pan = (function() {
        const offset = new THREE.Vector3();
        return function pan(deltaX, deltaY) {
          const element = scope.domElement;
          if (scope.object.isPerspectiveCamera) {
            const position = scope.object.position;
            offset.copy(position).sub(scope.target);
            let targetDistance = offset.length();
            targetDistance *= Math.tan((scope.object.fov / 2) * Math.PI / 180.0);
            panLeft(2 * deltaX * targetDistance / element.clientHeight, scope.object.matrix);
            panUp(2 * deltaY * targetDistance / element.clientHeight, scope.object.matrix);
          } else if (scope.object.isOrthographicCamera) {
            panLeft(deltaX * (scope.object.right - scope.object.left) / scope.object.zoom / element.clientWidth, scope.object.matrix);
            panUp(deltaY * (scope.object.top - scope.object.bottom) / scope.object.zoom / element.clientHeight, scope.object.matrix);
          }
        };
      })();

      function dollyOut(dollyScale) {
        if (scope.object.isPerspectiveCamera) {
          scale /= dollyScale;
        } else if (scope.object.isOrthographicCamera) {
          scope.object.zoom = Math.max(scope.minZoom, Math.min(scope.maxZoom, scope.object.zoom * dollyScale));
          scope.object.updateProjectionMatrix();
        }
      }

      function dollyIn(dollyScale) {
        if (scope.object.isPerspectiveCamera) {
          scale *= dollyScale;
        } else if (scope.object.isOrthographicCamera) {
          scope.object.zoom = Math.max(scope.minZoom, Math.min(scope.maxZoom, scope.object.zoom / dollyScale));
          scope.object.updateProjectionMatrix();
        }
      }

      function handleMouseDownRotate(event) {
        rotateStart.set(event.clientX, event.clientY);
      }

      function handleMouseDownDolly(event) {
        dollyStart.set(event.clientX, event.clientY);
      }

      function handleMouseDownPan(event) {
        panStart.set(event.clientX, event.clientY);
      }

      function handleMouseMoveRotate(event) {
        rotateEnd.set(event.clientX, event.clientY);
        rotateDelta.subVectors(rotateEnd, rotateStart).multiplyScalar(scope.rotateSpeed);
        const element = scope.domElement;
        rotateLeft(_twoPI * rotateDelta.x / element.clientHeight);
        rotateUp(_twoPI * rotateDelta.y / element.clientHeight);
        rotateStart.copy(rotateEnd);
        scope.update();
      }

      function handleMouseMoveDolly(event) {
        dollyEnd.set(event.clientX, event.clientY);
        dollyDelta.subVectors(dollyEnd, dollyStart);
        if (dollyDelta.y > 0) {
          dollyOut(getZoomScale());
        } else if (dollyDelta.y < 0) {
          dollyIn(getZoomScale());
        }
        dollyStart.copy(dollyEnd);
        scope.update();
      }

      function handleMouseMovePan(event) {
        panEnd.set(event.clientX, event.clientY);
        panDelta.subVectors(panEnd, panStart).multiplyScalar(scope.panSpeed);
        pan(panDelta.x, panDelta.y);
        panStart.copy(panEnd);
        scope.update();
      }

      function handleMouseWheel(event) {
        if (event.deltaY < 0) {
          dollyIn(getZoomScale());
        } else if (event.deltaY > 0) {
          dollyOut(getZoomScale());
        }
        scope.update();
      }

      function handleTouchStartRotate() {
        if (pointers.length === 1) {
          rotateStart.set(pointers[0].pageX, pointers[0].pageY);
        } else {
          const x = 0.5 * (pointers[0].pageX + pointers[1].pageX);
          const y = 0.5 * (pointers[0].pageY + pointers[1].pageY);
          rotateStart.set(x, y);
        }
      }

      function handleTouchStartPan() {
        if (pointers.length === 1) {
          panStart.set(pointers[0].pageX, pointers[0].pageY);
        } else {
          const x = 0.5 * (pointers[0].pageX + pointers[1].pageX);
          const y = 0.5 * (pointers[0].pageY + pointers[1].pageY);
          panStart.set(x, y);
        }
      }

      function handleTouchStartDolly() {
        const dx = pointers[0].pageX - pointers[1].pageX;
        const dy = pointers[0].pageY - pointers[1].pageY;
        const distance = Math.sqrt(dx * dx + dy * dy);
        dollyStart.set(0, distance);
      }

      function handleTouchMoveRotate(event) {
        if (pointers.length === 1) {
          rotateEnd.set(event.pageX, event.pageY);
        } else {
          const position = getSecondPointerPosition(event);
          const x = 0.5 * (event.pageX + position.x);
          const y = 0.5 * (event.pageY + position.y);
          rotateEnd.set(x, y);
        }
        rotateDelta.subVectors(rotateEnd, rotateStart).multiplyScalar(scope.rotateSpeed);
        const element = scope.domElement;
        rotateLeft(_twoPI * rotateDelta.x / element.clientHeight);
        rotateUp(_twoPI * rotateDelta.y / element.clientHeight);
        rotateStart.copy(rotateEnd);
      }

      function handleTouchMovePan(event) {
        if (pointers.length === 1) {
          panEnd.set(event.pageX, event.pageY);
        } else {
          const position = getSecondPointerPosition(event);
          const x = 0.5 * (event.pageX + position.x);
          const y = 0.5 * (event.pageY + position.y);
          panEnd.set(x, y);
        }
        panDelta.subVectors(panEnd, panStart).multiplyScalar(scope.panSpeed);
        pan(panDelta.x, panDelta.y);
        panStart.copy(panEnd);
      }

      function handleTouchMoveDolly(event) {
        const position = getSecondPointerPosition(event);
        const dx = event.pageX - position.x;
        const dy = event.pageY - position.y;
        const distance = Math.sqrt(dx * dx + dy * dy);
        dollyEnd.set(0, distance);
        dollyDelta.set(0, Math.pow(dollyEnd.y / dollyStart.y, scope.zoomSpeed));
        dollyOut(dollyDelta.y);
        dollyStart.copy(dollyEnd);
      }

      function onPointerDown(event) {
        if (scope.enabled === false) return;
        if (pointers.length === 0) {
          scope.domElement.setPointerCapture(event.pointerId);
          scope.domElement.addEventListener('pointermove', onPointerMove);
          scope.domElement.addEventListener('pointerup', onPointerUp);
        }
        addPointer(event);
        if (event.pointerType === 'touch') {
          onTouchStart(event);
        } else {
          onMouseDown(event);
        }
      }

      function onPointerMove(event) {
        if (scope.enabled === false) return;
        if (event.pointerType === 'touch') {
          onTouchMove(event);
        } else {
          onMouseMove(event);
        }
      }

      function onPointerUp(event) {
        removePointer(event);
        if (pointers.length === 0) {
          scope.domElement.releasePointerCapture(event.pointerId);
          scope.domElement.removeEventListener('pointermove', onPointerMove);
          scope.domElement.removeEventListener('pointerup', onPointerUp);
        }
        scope.dispatchEvent(_endEvent);
        state.current = _STATE.NONE;
      }

      function onMouseDown(event) {
        let mouseAction;
        switch (event.button) {
          case 0:
            mouseAction = scope.mouseButtons.LEFT;
            break;
          case 1:
            mouseAction = scope.mouseButtons.MIDDLE;
            break;
          case 2:
            mouseAction = scope.mouseButtons.RIGHT;
            break;
          default:
            mouseAction = -1;
        }
        switch (mouseAction) {
          case THREE.MOUSE.DOLLY:
            handleMouseDownDolly(event);
            state.current = _STATE.DOLLY;
            break;
          case THREE.MOUSE.ROTATE:
            if (event.ctrlKey || event.metaKey || event.shiftKey) {
              handleMouseDownPan(event);
              state.current = _STATE.PAN;
            } else {
              handleMouseDownRotate(event);
              state.current = _STATE.ROTATE;
            }
            break;
          case THREE.MOUSE.PAN:
            if (event.ctrlKey || event.metaKey || event.shiftKey) {
              handleMouseDownRotate(event);
              state.current = _STATE.ROTATE;
            } else {
              handleMouseDownPan(event);
              state.current = _STATE.PAN;
            }
            break;
          default:
            state.current = _STATE.NONE;
        }
        if (state.current !== _STATE.NONE) {
          scope.dispatchEvent(_startEvent);
        }
      }

      function onMouseMove(event) {
        switch (state.current) {
          case _STATE.ROTATE:
            handleMouseMoveRotate(event);
            break;
          case _STATE.DOLLY:
            handleMouseMoveDolly(event);
            break;
          case _STATE.PAN:
            handleMouseMovePan(event);
            break;
        }
      }

      function onMouseWheel(event) {
        if (scope.enabled === false || scope.enableZoom === false || state.current !== _STATE.NONE) return;
        event.preventDefault();
        scope.dispatchEvent(_startEvent);
        handleMouseWheel(event);
        scope.dispatchEvent(_endEvent);
      }

      function onTouchStart(event) {
        trackPointer(event);
        switch (pointers.length) {
          case 1:
            switch (scope.touches.ONE) {
              case THREE.TOUCH.ROTATE:
                handleTouchStartRotate();
                state.current = _STATE.TOUCH_ROTATE;
                break;
              case THREE.TOUCH.PAN:
                handleTouchStartPan();
                state.current = _STATE.TOUCH_PAN;
                break;
              default:
                state.current = _STATE.NONE;
            }
            break;
          case 2:
            switch (scope.touches.TWO) {
              case THREE.TOUCH.DOLLY_PAN:
                handleTouchStartDolly();
                handleTouchStartPan();
                state.current = _STATE.TOUCH_DOLLY_PAN;
                break;
              case THREE.TOUCH.DOLLY_ROTATE:
                handleTouchStartDolly();
                handleTouchStartRotate();
                state.current = _STATE.TOUCH_DOLLY_ROTATE;
                break;
              default:
                state.current = _STATE.NONE;
            }
            break;
          default:
            state.current = _STATE.NONE;
        }
        if (state.current !== _STATE.NONE) {
          scope.dispatchEvent(_startEvent);
        }
      }

      function onTouchMove(event) {
        trackPointer(event);
        switch (state.current) {
          case _STATE.TOUCH_ROTATE:
            handleTouchMoveRotate(event);
            scope.update();
            break;
          case _STATE.TOUCH_PAN:
            handleTouchMovePan(event);
            scope.update();
            break;
          case _STATE.TOUCH_DOLLY_PAN:
            handleTouchMoveDolly(event);
            handleTouchMovePan(event);
            scope.update();
            break;
          case _STATE.TOUCH_DOLLY_ROTATE:
            handleTouchMoveDolly(event);
            handleTouchMoveRotate(event);
            scope.update();
            break;
          default:
            state.current = _STATE.NONE;
        }
      }

      function onContextMenu(event) {
        if (scope.enabled === false) return;
        event.preventDefault();
      }

      function addPointer(event) {
        pointers.push(event);
      }

      function removePointer(event) {
        delete pointerPositions[event.pointerId];
        for (let i = 0; i < pointers.length; i++) {
          if (pointers[i].pointerId === event.pointerId) {
            pointers.splice(i, 1);
            return;
          }
        }
      }

      function trackPointer(event) {
        let position = pointerPositions[event.pointerId];
        if (position === undefined) {
          position = new THREE.Vector2();
          pointerPositions[event.pointerId] = position;
        }
        position.set(event.pageX, event.pageY);
      }

      function getSecondPointerPosition(event) {
        const pointer = (event.pointerId === pointers[0].pointerId) ? pointers[1] : pointers[0];
        return pointerPositions[pointer.pointerId];
      }

      this.update = (function() {
        const offset = new THREE.Vector3();
        const quat = new THREE.Quaternion().setFromUnitVectors(object.up, new THREE.Vector3(0, 1, 0));
        const quatInverse = quat.clone().invert();
        const lastPosition = new THREE.Vector3();
        const lastQuaternion = new THREE.Quaternion();

        return function update() {
          const position = scope.object.position;
          offset.copy(position).sub(scope.target);
          offset.applyQuaternion(quat);
          spherical.setFromVector3(offset);

          if (scope.autoRotate && state.current === _STATE.NONE) {
            rotateLeft(getAutoRotationAngle());
          }

          if (scope.enableDamping) {
            spherical.theta += sphericalDelta.theta * scope.dampingFactor;
            spherical.phi += sphericalDelta.phi * scope.dampingFactor;
          } else {
            spherical.theta += sphericalDelta.theta;
            spherical.phi += sphericalDelta.phi;
          }

          let min = scope.minAzimuthAngle;
          let max = scope.maxAzimuthAngle;
          if (isFinite(min) && isFinite(max)) {
            if (min < -Math.PI) min += _twoPI; else if (min > Math.PI) min -= _twoPI;
            if (max < -Math.PI) max += _twoPI; else if (max > Math.PI) max -= _twoPI;
            if (min <= max) {
              spherical.theta = Math.max(min, Math.min(max, spherical.theta));
            } else {
              spherical.theta = (spherical.theta > (min + max) / 2) ?
                Math.max(min, spherical.theta) :
                Math.min(max, spherical.theta);
            }
          }

          spherical.phi = Math.max(scope.minPolarAngle, Math.min(scope.maxPolarAngle, spherical.phi));
          spherical.makeSafe();
          spherical.radius *= scale;
          spherical.radius = Math.max(scope.minDistance, Math.min(scope.maxDistance, spherical.radius));

          if (scope.enableDamping === true) {
            scope.target.addScaledVector(panOffset, scope.dampingFactor);
          } else {
            scope.target.add(panOffset);
          }

          offset.setFromSpherical(spherical);
          offset.applyQuaternion(quatInverse);
          position.copy(scope.target).add(offset);
          scope.object.lookAt(scope.target);

          if (scope.enableDamping === true) {
            sphericalDelta.theta *= (1 - scope.dampingFactor);
            sphericalDelta.phi *= (1 - scope.dampingFactor);
            panOffset.multiplyScalar(1 - scope.dampingFactor);
          } else {
            sphericalDelta.set(0, 0, 0);
            panOffset.set(0, 0, 0);
          }

          scale = 1;

          if (lastPosition.distanceToSquared(scope.object.position) > _EPS ||
              8 * (1 - lastQuaternion.dot(scope.object.quaternion)) > _EPS) {
            scope.dispatchEvent(_changeEvent);
            lastPosition.copy(scope.object.position);
            lastQuaternion.copy(scope.object.quaternion);
            return true;
          }
          return false;
        };
      })();

      this.dispose = function() {
        scope.domElement.removeEventListener('contextmenu', onContextMenu);
        scope.domElement.removeEventListener('pointerdown', onPointerDown);
        scope.domElement.removeEventListener('pointercancel', onPointerUp);
        scope.domElement.removeEventListener('wheel', onMouseWheel);
        scope.domElement.removeEventListener('pointermove', onPointerMove);
        scope.domElement.removeEventListener('pointerup', onPointerUp);
        if (scope._domElementKeyEvents !== null) {
          scope._domElementKeyEvents.removeEventListener('keydown', onKeyDown);
          scope._domElementKeyEvents = null;
        }
      };

      this.reset = function() {
        scope.target.copy(scope.target0);
        scope.object.position.copy(scope.position0);
        scope.object.zoom = scope.zoom0;
        scope.object.updateProjectionMatrix();
        scope.dispatchEvent(_changeEvent);
        scope.update();
        state.current = _STATE.NONE;
      };

      function onKeyDown(event) {
        if (scope.enabled === false || scope.enablePan === false) return;
        switch (event.code) {
          case scope.keys.UP:
            pan(0, scope.keyPanSpeed);
            scope.update();
            break;
          case scope.keys.BOTTOM:
            pan(0, -scope.keyPanSpeed);
            scope.update();
            break;
          case scope.keys.LEFT:
            pan(scope.keyPanSpeed, 0);
            scope.update();
            break;
          case scope.keys.RIGHT:
            pan(-scope.keyPanSpeed, 0);
            scope.update();
            break;
        }
      }

      this.listenToKeyEvents = function(domElement) {
        domElement.addEventListener('keydown', onKeyDown);
        this._domElementKeyEvents = domElement;
      };

      this.stopListenToKeyEvents = function() {
        this._domElementKeyEvents.removeEventListener('keydown', onKeyDown);
        this._domElementKeyEvents = null;
      };

      scope.domElement.addEventListener('contextmenu', onContextMenu);
      scope.domElement.addEventListener('pointerdown', onPointerDown);
      scope.domElement.addEventListener('pointercancel', onPointerUp);
      scope.domElement.addEventListener('wheel', onMouseWheel, { passive: false });

      this.update();
    }
  }

  THREE.OrbitControls = OrbitControls;
})();
