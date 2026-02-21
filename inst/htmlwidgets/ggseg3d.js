HTMLWidgets.widget({
  name: 'ggseg3d',
  type: 'output',

  factory: function(el, width, height) {
    var renderer = null;
    var tooltip = null;
    var colorbar = null;
    var container = null;

    return {
      renderValue: function(x) {
        if (renderer) {
          renderer.dispose();
        }
        if (tooltip) {
          tooltip.dispose();
        }
        if (colorbar) {
          colorbar.dispose();
        }

        el.innerHTML = '';

        container = document.createElement('div');
        container.className = 'ggseg3d-container';
        container.style.width = width + 'px';
        container.style.height = height + 'px';
        container.style.position = 'relative';
        el.appendChild(container);

        var options = x.options || {};
        renderer = new BrainMeshRenderer(container, {
          backgroundColor: options.backgroundColor || '#ffffff',
          antialias: true,
          enableDamping: true,
          flatShading: options.flatShading || false,
          orthographic: options.orthographic || false,
          frustumSize: options.frustumSize || null
        });

        if (x.meshes && x.meshes.length > 0) {
          for (var i = 0; i < x.meshes.length; i++) {
            var meshData = x.meshes[i];
            renderer.addMesh({
              name: meshData.name || 'region_' + i,
              vertices: meshData.vertices,
              faces: meshData.faces,
              colors: meshData.colors,
              colorMode: meshData.colorMode || 'facecolor',
              opacity: meshData.opacity !== undefined ? meshData.opacity : 1.0,
              hoverText: meshData.hoverText || null,
              vertexLabels: meshData.vertexLabels || null,
              vertexTexts: meshData.vertexTexts || null,
              edgeColor: meshData.edgeColor || null,
              edgeWidth: meshData.edgeWidth || null,
              boundaryEdges: meshData.boundaryEdges || null
            });
          }
        }

        renderer.centerOnMeshes();

        if (options.camera) {
          renderer.setCamera(options.camera);
        }

        if (options.orthographic && options.autoFit) {
          renderer.fitToMeshes();
        }

        tooltip = new TooltipManager(container);

        container.addEventListener('mousemove', function(event) {
          var mesh = renderer.getMeshAtPoint(event.clientX, event.clientY);
          if (mesh) {
            var content = '<strong>' + (mesh.userData.name || 'Unknown') + '</strong>';
            if (mesh.userData.hoverText) {
              content += '<br>' + mesh.userData.hoverText;
            }
            tooltip.show(event.clientX, event.clientY, content);
          } else {
            tooltip.hide();
          }
        });

        container.addEventListener('mouseleave', function() {
          tooltip.hide();
        });

        if (x.colorbar && options.showLegend !== false) {
          colorbar = new ColorbarOverlay(container);
          colorbar.create(x.colorbar);
        }

        if (typeof Shiny !== 'undefined') {
          Shiny.addCustomMessageHandler('ggseg3d-camera-' + el.id, function(camera) {
            if (renderer) {
              renderer.setCamera(camera);
            }
          });

          Shiny.addCustomMessageHandler('ggseg3d-background-' + el.id, function(color) {
            if (renderer) {
              renderer.setBackgroundColor(color);
            }
          });
        }
      },

      resize: function(width, height) {
        if (container) {
          container.style.width = width + 'px';
          container.style.height = height + 'px';
        }
        if (renderer) {
          renderer.resize(width, height);
        }
      }
    };
  }
});
