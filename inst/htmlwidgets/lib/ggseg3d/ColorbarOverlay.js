(function() {
  'use strict';

  class ColorbarOverlay {
    constructor(container) {
      this.container = container;
      this.element = null;
    }

    create(config) {
      if (!config || !config.colors || config.colors.length === 0) {
        return;
      }

      this.remove();

      if (config.type === 'discrete') {
        this._createDiscrete(config);
      } else {
        this._createContinuous(config);
      }
    }

    _createContinuous(config) {
      const { title, min, max, colors, breakpoints } = config;
      const gradientHeight = 150;

      this.element = document.createElement('div');
      this.element.className = 'ggseg3d-colorbar';
      this.element.style.cssText = `
        position: absolute;
        right: 20px;
        top: 50%;
        transform: translateY(-50%);
        font-family: sans-serif;
        font-size: 11px;
        color: #333;
        background: rgba(255, 255, 255, 0.9);
        padding: 8px;
        border-radius: 4px;
      `;

      const titleEl = document.createElement('div');
      titleEl.textContent = title || '';
      titleEl.style.cssText = `
        text-align: center;
        font-weight: 500;
        margin-bottom: 4px;
      `;
      this.element.appendChild(titleEl);

      const barRow = document.createElement('div');
      barRow.style.cssText = `
        display: flex;
        flex-direction: row;
      `;

      const gradient = document.createElement('div');
      let gradientStops;

      if (breakpoints && breakpoints.length === colors.length) {
        const stops = [];
        for (let i = 0; i < colors.length; i++) {
          const pct = ((max - breakpoints[i]) / (max - min)) * 100;
          stops.push({ color: colors[i], pct: pct });
        }
        stops.sort((a, b) => a.pct - b.pct);
        gradientStops = stops.map(s => `${s.color} ${s.pct}%`).join(', ');
      } else {
        const reversed = colors.slice().reverse();
        gradientStops = reversed.map((c, i) =>
          `${c} ${(i / (reversed.length - 1)) * 100}%`
        ).join(', ');
      }

      gradient.style.cssText = `
        width: 20px;
        height: ${gradientHeight}px;
        background: linear-gradient(to bottom, ${gradientStops});
        border: 1px solid #ccc;
        border-radius: 2px;
      `;
      barRow.appendChild(gradient);

      const ticksDiv = document.createElement('div');
      ticksDiv.style.cssText = `
        position: relative;
        width: 40px;
        height: ${gradientHeight}px;
        margin-left: 2px;
      `;

      const numTicks = 5;
      for (let i = 0; i < numTicks; i++) {
        const pct = (i / (numTicks - 1)) * 100;
        const value = max - (i / (numTicks - 1)) * (max - min);
        const tick = document.createElement('div');
        tick.style.cssText = `
          position: absolute;
          top: ${pct}%;
          left: 0;
          transform: translateY(-50%);
          display: flex;
          align-items: center;
        `;
        const line = document.createElement('span');
        line.style.cssText = `
          display: inline-block;
          width: 4px;
          height: 1px;
          background: #666;
        `;
        const label = document.createElement('span');
        label.textContent = this._formatNumber(value);
        label.style.marginLeft = '2px';
        tick.appendChild(line);
        tick.appendChild(label);
        ticksDiv.appendChild(tick);
      }

      barRow.appendChild(ticksDiv);
      this.element.appendChild(barRow);
      this.container.appendChild(this.element);
    }

    _createDiscrete(config) {
      const { title, labels, colors } = config;

      this.element = document.createElement('div');
      this.element.className = 'ggseg3d-legend';
      this.element.style.cssText = `
        position: absolute;
        right: 10px;
        top: 50%;
        transform: translateY(-50%);
        max-height: 80%;
        overflow-y: auto;
        background: rgba(255, 255, 255, 0.9);
        padding: 8px;
        border-radius: 4px;
        font-family: sans-serif;
        font-size: 10px;
        color: #333;
      `;

      if (title) {
        const titleEl = document.createElement('div');
        titleEl.textContent = title;
        titleEl.style.cssText = `
          font-weight: 600;
          margin-bottom: 6px;
          padding-bottom: 4px;
          border-bottom: 1px solid #ddd;
        `;
        this.element.appendChild(titleEl);
      }

      for (let i = 0; i < labels.length && i < colors.length; i++) {
        const item = document.createElement('div');
        item.style.cssText = `
          display: flex;
          align-items: center;
          gap: 6px;
          margin-bottom: 2px;
        `;

        const swatch = document.createElement('div');
        swatch.style.cssText = `
          width: 12px;
          height: 12px;
          background-color: ${colors[i]};
          border: 1px solid #999;
          border-radius: 2px;
          flex-shrink: 0;
        `;
        item.appendChild(swatch);

        const labelEl = document.createElement('span');
        labelEl.textContent = labels[i];
        labelEl.style.cssText = `
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
          max-width: 120px;
        `;
        item.appendChild(labelEl);

        this.element.appendChild(item);
      }

      this.container.appendChild(this.element);
    }

    _formatNumber(num) {
      if (num === undefined || num === null) return '';
      if (Math.abs(num) >= 1000 || (Math.abs(num) < 0.01 && num !== 0)) {
        return num.toExponential(1);
      }
      return num.toFixed(2).replace(/\.?0+$/, '');
    }

    remove() {
      if (this.element && this.element.parentNode) {
        this.element.parentNode.removeChild(this.element);
        this.element = null;
      }
    }

    dispose() {
      this.remove();
    }
  }

  window.ColorbarOverlay = ColorbarOverlay;
})();
