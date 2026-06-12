/**
 * topbar - Yet another topbar :3
 * @version v1.1.0
 * @license MIT
 */
(function (self) {
  'use strict';

  if (self.Topbar) return;

  var Topbar = function () {
    var progress = 0,
      elements,
      currentProgress,
      show,
      hide,
      bar,
      prefix = "progressbar";

    var options = {
      autoRun: true,
      barThickness: 3,
      barColors: {
        '0': '#3b82f6',
        '0.5': '#60a5fa',
        '1.0': '#93c5fd'
      },
      shadowColor: 'rgba(0, 0, 0, .1)',
      shadowBlur: 10,
      shadowOffset: '0 3px',
      className: null
    };

    var addClass = function (el, cls) {
      el.className += ' ' + cls;
    };

    var removeClass = function (el, cls) {
      var reg = new RegExp('(^|\\s)' + cls + '(\\s|$)', 'g');
      el.className = el.className.replace(reg, ' ').replace(/^\s+|\s+$/g, '');
    };

    var createBar = function () {
      bar = document.createElement('div');
      bar.className = prefix;
      bar.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:' + options.barThickness + 'px;z-index:99999;transition:all .2s ease-out;pointer-events:none;box-shadow:' + options.shadowColor + ' 0 ' + options.shadowOffset + ' ' + options.shadowBlur + ';';
      var progress = document.createElement('div');
      progress.style.cssText = 'width:0;height:100%;transition:all .25s ease-out;';
      bar.appendChild(progress);
      document.body.appendChild(bar);
      return progress;
    };

    var setProgress = function (prog) {
      currentProgress = prog;
      bar.firstChild.style.cssText = 'width:' + prog + '%;height:100%;background:' + getGradient(prog) + ';transition:all .25s ease-out;';
    };

    var getGradient = function (prog) {
      var gradient = '';
      for (var pos in options.barColors) {
        gradient += (pos * 100) + '% ' + options.barColors[pos] + ',';
      }
      return 'linear-gradient(to right, ' + gradient.slice(0, -1) + ')';
    };

    var show = function (at) {
      if (typeof at !== 'number') at = 0;
      setProgress(at);
      bar.style.opacity = '1';
    };

    var hide = function () {
      bar.style.opacity = '0';
      setTimeout(function () {
        setProgress(0);
      }, 300);
    };

    var config = function (opts) {
      for (var k in opts) {
        options[k] = opts[k];
      }
    };

    var set = function (n) {
      var target = n || 0;
      show(target);
      if (target === 100) {
        hide();
      }
    };

    var inc = function (amount) {
      var n = currentProgress;
      if (!n) n = 0;
      if (typeof amount !== 'number') amount = 1;
      set(n + amount);
    };

    var start = function () {
      if (!bar) createBar();
      show(0);
      if (options.autoRun) {
        setTimeout(function () { inc(0.3); }, 300);
      }
    };

    var status = function () { return currentProgress; };

    return {
      config: config,
      start: start,
      set: set,
      inc: inc,
      hide: hide,
      status: status
    };
  };

  self.Topbar = Topbar;
})(typeof window !== 'undefined' ? window : this);
