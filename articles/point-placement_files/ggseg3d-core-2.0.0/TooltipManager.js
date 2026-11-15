(function() {
  'use strict';

  class TooltipManager {
    constructor(container) {
      this.container = container;
      this.tooltip = null;
      this._createTooltip();
    }

    _createTooltip() {
      this.tooltip = document.createElement('div');
      this.tooltip.className = 'ggseg3d-tooltip';
      this.tooltip.style.cssText = `
        position: absolute;
        display: none;
        background: rgba(0, 0, 0, 0.8);
        color: white;
        padding: 8px 12px;
        border-radius: 4px;
        font-size: 12px;
        font-family: sans-serif;
        pointer-events: none;
        z-index: 1000;
        max-width: 250px;
        word-wrap: break-word;
        box-shadow: 0 2px 8px rgba(0,0,0,0.3);
      `;
      this.container.appendChild(this.tooltip);
    }

    show(x, y, content) {
      this.tooltip.innerHTML = content;
      this.tooltip.style.display = 'block';

      const rect = this.container.getBoundingClientRect();
      const tooltipRect = this.tooltip.getBoundingClientRect();

      let left = x - rect.left + 15;
      let top = y - rect.top + 15;

      if (left + tooltipRect.width > rect.width) {
        left = x - rect.left - tooltipRect.width - 15;
      }
      if (top + tooltipRect.height > rect.height) {
        top = y - rect.top - tooltipRect.height - 15;
      }

      this.tooltip.style.left = left + 'px';
      this.tooltip.style.top = top + 'px';
    }

    hide() {
      this.tooltip.style.display = 'none';
    }

    dispose() {
      if (this.tooltip && this.tooltip.parentNode) {
        this.tooltip.parentNode.removeChild(this.tooltip);
      }
    }
  }

  window.TooltipManager = TooltipManager;
})();
