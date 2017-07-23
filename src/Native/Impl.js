var _seurimas$whistle$Native_Impl = function () {
  var nativeBinding = _elm_lang$core$Native_Scheduler.nativeBinding;
  var succeed = _elm_lang$core$Native_Scheduler.succeed;
  var receive = _elm_lang$core$Native_Scheduler.receive;
  var fail = _elm_lang$core$Native_Scheduler.fail;
  var audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  /** Helpers */
  function getNewNode(node, config) {
    var audioNode = {
      realNode: function() {
        return node; // Sneak me past Elm "customs".
      },
      nodeType: config.nodeType,
      destination: config.destination,
      source: config.source,
    };
    return audioNode;
  }
  function nodeError(nodeObj, callback, errorString) {
    callback(fail(errorString + ": " + JSON.stringify(nodeObj)));
  }
  function getApiNode(nodeObj) {
    return nodeObj.realNode();
  }
  /** Microphone */
  var microphoneNode = null;
  function getMicrophoneStream() {
    return nativeBinding(function(callback) {
      if (microphoneNode !== null) {
        callback(succeed(audioNodes[microphoneStreamId]));
        return;
      }
      navigator.mediaDevices.getUserMedia({ audio: true}).then(
      function(stream) {
        var microphone = audioCtx.createMediaStreamSource(stream);
        microphoneNode = getNewNode(microphone, {
          nodeType: 'microphone',
          destination: false,
          source: true,
        })
        callback(succeed(microphoneNode));
      }, function(err) {
        callback(fail('getUserMedia failed: ' + err));
      });
    });
  }
  /** Buffers */
  function getAudioData(url) {
    return nativeBinding(function(callback) {
      var xhr = new XMLHttpRequest();
      xhr.open('GET', url, true);
      xhr.responseType = 'arraybuffer';
      xhr.addEventListener("load", function() {
        audioCtx.decodeAudioData(xhr.response, function(buffer) {
          callback(succeed(function() {
            return buffer; // Sneak me past Elm "customs".
          }));
        }, function(error) {
          callback(fail(JSON.stringify(error)));
        })
      });
      xhr.addEventListener("error", function(evt) {
        callback(fail(JSON.stringify(evt)));
      });
      xhr.send();
    });
  }
  function createBufferSource(loop, bufferFn) {
    return nativeBinding(function(callback) {
      var node = audioCtx.createBufferSource();
      node.buffer = bufferFn();
      node.loop = loop;
      callback(succeed(getNewNode(node, {
        nodeType: 'buffer',
        destination: false,
        source: true,
      })));
    });
  }
  function startSource(time, nodeObj) {
    return nativeBinding(function(callback) {
      if (nodeObj.nodeType !== 'buffer') {
        nodeError(nodeObj, callback, 'Not a buffer source node');
      } else {
        getApiNode(nodeObj).start(time);
        callback(succeed(nodeObj));
      }
    });
  }
  function stopSource(nodeObj) {
    return nativeBinding(function(callback) {
      if (nodeObj.nodeType !== 'buffer') {
        nodeError(nodeObj, callback, 'Not a buffer source node');
      } else {
        getApiNode(nodeObj).stop();
        callback(succeed(nodeObj));
      }
    });
  }
  /** Other audio nodes */
  function createOscillator(type, frequency) {
    return nativeBinding(function(callback) {
      var oscillator = audioCtx.createOscillator();
      oscillator.frequency.value = frequency;
      oscillator.start();
      callback(succeed(getNewNode(oscillator, {
        nodeType: 'oscillator',
        destination: false,
        source: true,
      })));
    });
  }
  function createGainNode(initialValue) {
    return nativeBinding(function(callback) {
      var gain = audioCtx.createGain();
      gain.gain.value = initialValue;
      callback(succeed(getNewNode(gain, {
        nodeType: 'gain',
        destination: true,
        source: true,
      })));
    });
  }
  function changeGain(newValue, nodeObj) {
    return nativeBinding(function(callback) {
      if (nodeObj.nodeType !== 'gain') {
        nodeError(nodeObj, callback, 'Not a gain node');
      } else  {
        getApiNode(nodeObj).gain.value = newValue;
        callback(succeed(nodeObj));
      }
    });
  }
  function connect(source, destination) {
    return nativeBinding(function(callback) {
      if (!source.source) {
        nodeError(source, callback, 'Not a source');
      } else if (!destination.destination) {
        nodeError(destination, callback, 'Not a destination');
      } else {
        getApiNode(source).connect(getApiNode(destination));
        callback(succeed(destination));
      }
    });
  }
  var audioContextDestination = getNewNode(audioCtx.destination, {
    destination: true,
    source: false,
    type: 'context',
  });
  return {
    audioContextDestination: audioContextDestination, // Pure value.
    getMicrophoneStream: getMicrophoneStream(), // F0
    getAudioData: getAudioData, // F1
    createBufferSource: F2(createBufferSource),
    startSource: F2(startSource),
    stopSource: F2(stopSource),
    createOscillator: F2(createOscillator),
    createGainNode: createGainNode, // F1
    changeGain: F2(changeGain),
    connect: F2(connect),
  }
}();
