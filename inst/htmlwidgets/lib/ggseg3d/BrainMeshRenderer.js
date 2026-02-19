(function() {
  'use strict';

  const CAMERA_PRESETS = {
    'left lateral': { x: -350, y: 0, z: 0 },
    'left_lateral': { x: -350, y: 0, z: 0 },
    'left medial': { x: 350, y: 0, z: 0 },
    'left_medial': { x: 350, y: 0, z: 0 },
    'right lateral': { x: 350, y: 0, z: 0 },
    'right_lateral': { x: 350, y: 0, z: 0 },
    'right medial': { x: -350, y: 0, z: 0 },
    'right_medial': { x: -350, y: 0, z: 0 },
    'left superior': { x: -120, y: 0, z: 330 },
    'left_superior': { x: -120, y: 0, z: 330 },
    'right superior': { x: 120, y: 0, z: 330 },
    'right_superior': { x: 120, y: 0, z: 330 },
    'left inferior': { x: -120, y: 0, z: -330 },
    'left_inferior': { x: -120, y: 0, z: -330 },
    'right inferior': { x: 120, y: 0, z: -330 },
    'right_inferior': { x: 120, y: 0, z: -330 },
    'left anterior': { x: -120, y: 330, z: 0 },
    'left_anterior': { x: -120, y: 330, z: 0 },
    'right anterior': { x: 120, y: 330, z: 0 },
    'right_anterior': { x: 120, y: 330, z: 0 },
    'left posterior': { x: -120, y: -330, z: 0 },
    'left_posterior': { x: -120, y: -330, z: 0 },
    'right posterior': { x: 120, y: -330, z: 0 },
    'right_posterior': { x: 120, y: -330, z: 0 }
  };

  class BrainMeshRenderer {
    constructor(container, options = {}) {
      this.container = container;
      this.options = Object.assign({
        backgroundColor: 0xffffff,
        enableDamping: true,
        dampingFactor: 0.05,
        antialias: true,
        flatShading: false,
        orthographic: false
      }, options);

      this.meshes = [];
      this.meshData = [];
      this.scene = null;
      this.camera = null;
      this.renderer = null;
      this.controls = null;
      this.animationId = null;
      this.raycaster = new THREE.Raycaster();
      this.mouse = new THREE.Vector2();
      this.hoveredMesh = null;

      this._init();
    }

    _init() {
      const width = this.container.clientWidth || 400;
      const height = this.container.clientHeight || 400;

      this.scene = new THREE.Scene();
      this.scene.background = new THREE.Color(this.options.backgroundColor);

      if (this.options.orthographic) {
        const frustumSize = this.options.frustumSize || 220;
        const aspect = width / height;
        this.camera = new THREE.OrthographicCamera(
          -frustumSize * aspect / 2,
          frustumSize * aspect / 2,
          frustumSize / 2,
          -frustumSize / 2,
          1,
          1000
        );
      } else {
        this.camera = new THREE.PerspectiveCamera(45, width / height, 1, 1000);
      }
      this.camera.up.set(0, 0, 1);
      this.camera.position.set(350, 0, 0);
      this.camera.lookAt(0, 0, 0);

      this.renderer = new THREE.WebGLRenderer({
        antialias: this.options.antialias,
        alpha: true
      });
      this.renderer.setSize(width, height);
      this.renderer.setPixelRatio(window.devicePixelRatio);
      this.container.appendChild(this.renderer.domElement);

      const ambientLight = new THREE.AmbientLight(0xffffff, 0.6);
      this.scene.add(ambientLight);

      const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
      directionalLight.position.set(1, 1, 1);
      this.scene.add(directionalLight);

      const directionalLight2 = new THREE.DirectionalLight(0xffffff, 0.4);
      directionalLight2.position.set(-1, -1, -1);
      this.scene.add(directionalLight2);

      this.controls = new THREE.OrbitControls(this.camera, this.renderer.domElement);
      this.controls.enableDamping = this.options.enableDamping;
      this.controls.dampingFactor = this.options.dampingFactor;
      this.controls.screenSpacePanning = false;
      this.controls.minDistance = 50;
      this.controls.maxDistance = 500;

      this._animate();

      window.addEventListener('resize', () => this._onResize());
    }

    _animate() {
      this.animationId = requestAnimationFrame(() => this._animate());
      this.controls.update();
      this.renderer.render(this.scene, this.camera);
    }

    _onResize() {
      const width = this.container.clientWidth;
      const height = this.container.clientHeight;
      this.camera.aspect = width / height;
      this.camera.updateProjectionMatrix();
      this.renderer.setSize(width, height);
    }

    addMesh(meshData) {
      const { vertices, faces, colors, colorMode, opacity, name, hoverText,
              edgeColor, edgeWidth, boundaryEdges, vertexLabels,
              vertexTexts } = meshData;

      let geometry;
      let material;

      if (colorMode === 'vertexcolor') {
        geometry = this._createIndexedGeometry(vertices, faces, colors);
      } else {
        geometry = this._createFaceColorGeometry(vertices, faces, colors);
      }

      geometry.computeVertexNormals();

      if (this.options.flatShading) {
        material = new THREE.MeshBasicMaterial({
          vertexColors: true,
          side: THREE.DoubleSide,
          transparent: opacity < 1,
          opacity: opacity
        });
      } else {
        material = new THREE.MeshPhongMaterial({
          vertexColors: true,
          side: THREE.DoubleSide,
          transparent: opacity < 1,
          opacity: opacity
        });
      }

      const mesh = new THREE.Mesh(geometry, material);
      mesh.userData = { name, hoverText, originalColors: colors, vertexLabels, vertexTexts };
      this.scene.add(mesh);
      this.meshes.push(mesh);
      this.meshData.push(meshData);

      if (edgeColor && colorMode === 'facecolor') {
        this._addMeshEdges(mesh, geometry, edgeColor, edgeWidth || 1);
      }

      if (edgeColor && boundaryEdges && boundaryEdges.length > 0) {
        this._addBoundaryEdges(vertices, boundaryEdges, edgeColor, edgeWidth || 1);
      }

      return mesh;
    }

    _addMeshEdges(mesh, geometry, edgeColor, edgeWidth) {
      const edges = new THREE.EdgesGeometry(geometry, 15);
      const lineMaterial = new THREE.LineBasicMaterial({
        color: new THREE.Color(edgeColor),
        linewidth: edgeWidth
      });
      const wireframe = new THREE.LineSegments(edges, lineMaterial);
      mesh.add(wireframe);
    }

    _addBoundaryEdges(vertices, boundaryEdges, edgeColor, edgeWidth) {
      const positions = new Float32Array(boundaryEdges.length * 6);

      for (let i = 0; i < boundaryEdges.length; i++) {
        const v1 = boundaryEdges[i][0];
        const v2 = boundaryEdges[i][1];

        positions[i * 6] = vertices.x[v1];
        positions[i * 6 + 1] = vertices.y[v1];
        positions[i * 6 + 2] = vertices.z[v1];
        positions[i * 6 + 3] = vertices.x[v2];
        positions[i * 6 + 4] = vertices.y[v2];
        positions[i * 6 + 5] = vertices.z[v2];
      }

      const geometry = new THREE.BufferGeometry();
      geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));

      const material = new THREE.LineBasicMaterial({
        color: new THREE.Color(edgeColor),
        linewidth: edgeWidth
      });

      const lines = new THREE.LineSegments(geometry, material);
      this.scene.add(lines);
      this.meshes.push(lines);
    }

    _createIndexedGeometry(vertices, faces, colors) {
      const geometry = new THREE.BufferGeometry();

      const positions = new Float32Array(vertices.x.length * 3);
      for (let i = 0; i < vertices.x.length; i++) {
        positions[i * 3] = vertices.x[i];
        positions[i * 3 + 1] = vertices.y[i];
        positions[i * 3 + 2] = vertices.z[i];
      }
      geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));

      const indices = new Uint32Array(faces.i.length * 3);
      for (let i = 0; i < faces.i.length; i++) {
        indices[i * 3] = faces.i[i];
        indices[i * 3 + 1] = faces.j[i];
        indices[i * 3 + 2] = faces.k[i];
      }
      geometry.setIndex(new THREE.BufferAttribute(indices, 1));

      const colorAttr = new Float32Array(vertices.x.length * 3);
      for (let i = 0; i < colors.length; i++) {
        const color = new THREE.Color(colors[i]);
        colorAttr[i * 3] = color.r;
        colorAttr[i * 3 + 1] = color.g;
        colorAttr[i * 3 + 2] = color.b;
      }
      geometry.setAttribute('color', new THREE.BufferAttribute(colorAttr, 3));

      return geometry;
    }

    _createFaceColorGeometry(vertices, faces, colors) {
      const geometry = new THREE.BufferGeometry();
      const numFaces = faces.i.length;

      const positions = new Float32Array(numFaces * 9);
      const colorAttr = new Float32Array(numFaces * 9);

      for (let f = 0; f < numFaces; f++) {
        const i = faces.i[f];
        const j = faces.j[f];
        const k = faces.k[f];

        positions[f * 9] = vertices.x[i];
        positions[f * 9 + 1] = vertices.y[i];
        positions[f * 9 + 2] = vertices.z[i];

        positions[f * 9 + 3] = vertices.x[j];
        positions[f * 9 + 4] = vertices.y[j];
        positions[f * 9 + 5] = vertices.z[j];

        positions[f * 9 + 6] = vertices.x[k];
        positions[f * 9 + 7] = vertices.y[k];
        positions[f * 9 + 8] = vertices.z[k];

        const faceColor = colors[f] || colors[0];
        const color = new THREE.Color(faceColor);

        for (let v = 0; v < 3; v++) {
          colorAttr[f * 9 + v * 3] = color.r;
          colorAttr[f * 9 + v * 3 + 1] = color.g;
          colorAttr[f * 9 + v * 3 + 2] = color.b;
        }
      }

      geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
      geometry.setAttribute('color', new THREE.BufferAttribute(colorAttr, 3));

      return geometry;
    }

    setCamera(cameraSpec) {
      let eye;
      if (typeof cameraSpec === 'string') {
        eye = CAMERA_PRESETS[cameraSpec] || CAMERA_PRESETS['right lateral'];
      } else if (cameraSpec && cameraSpec.eye) {
        eye = cameraSpec.eye;
      } else {
        eye = cameraSpec || { x: 350, y: 0, z: 0 };
      }

      const target = this.controls.target;
      this.camera.position.set(
        target.x + eye.x,
        target.y + eye.y,
        target.z + eye.z
      );
      this.camera.lookAt(target);
      this.controls.update();
    }

    setBackgroundColor(color) {
      this.scene.background = new THREE.Color(color);
    }

    centerOnMeshes() {
      if (this.meshes.length === 0) return;

      const box = new THREE.Box3();
      for (const mesh of this.meshes) {
        box.expandByObject(mesh);
      }

      const center = new THREE.Vector3();
      box.getCenter(center);

      this.controls.target.copy(center);
      this.camera.lookAt(center);
      this.controls.update();
    }

    fitToMeshes(padding = 1.1) {
      this.centerOnMeshes();
      if (this.meshes.length === 0) return;

      const box = new THREE.Box3();
      for (const mesh of this.meshes) {
        box.expandByObject(mesh);
      }

      const size = new THREE.Vector3();
      box.getSize(size);
      const maxDim = Math.max(size.x, size.y, size.z) * padding;

      if (this.camera.isOrthographicCamera) {
        const width = this.container.clientWidth || 400;
        const height = this.container.clientHeight || 400;
        const aspect = width / height;

        this.camera.left = -maxDim * aspect / 2;
        this.camera.right = maxDim * aspect / 2;
        this.camera.top = maxDim / 2;
        this.camera.bottom = -maxDim / 2;
        this.camera.updateProjectionMatrix();
      }
    }

    clearMeshes() {
      for (const mesh of this.meshes) {
        this.scene.remove(mesh);
        mesh.geometry.dispose();
        mesh.material.dispose();
      }
      this.meshes = [];
      this.meshData = [];
    }

    getMeshAtPoint(x, y) {
      const rect = this.renderer.domElement.getBoundingClientRect();
      this.mouse.x = ((x - rect.left) / rect.width) * 2 - 1;
      this.mouse.y = -((y - rect.top) / rect.height) * 2 + 1;

      this.raycaster.setFromCamera(this.mouse, this.camera);
      const intersects = this.raycaster.intersectObjects(this.meshes);

      if (intersects.length > 0) {
        const intersect = intersects[0];
        const mesh = intersect.object;

        if (mesh.userData.vertexLabels && intersect.face) {
          const vertexIndex = intersect.face.a;
          const label = mesh.userData.vertexLabels[vertexIndex];
          if (label) {
            const vertexText = mesh.userData.vertexTexts
              ? mesh.userData.vertexTexts[vertexIndex]
              : null;
            return {
              userData: {
                name: label,
                hoverText: vertexText || mesh.userData.hoverText
              }
            };
          }
        }

        return mesh;
      }
      return null;
    }

    dispose() {
      if (this.animationId) {
        cancelAnimationFrame(this.animationId);
      }
      this.clearMeshes();
      this.controls.dispose();
      this.renderer.dispose();
      if (this.container.contains(this.renderer.domElement)) {
        this.container.removeChild(this.renderer.domElement);
      }
    }

    resize(width, height) {
      this.camera.aspect = width / height;
      this.camera.updateProjectionMatrix();
      this.renderer.setSize(width, height);
    }
  }

  window.BrainMeshRenderer = BrainMeshRenderer;
})();
