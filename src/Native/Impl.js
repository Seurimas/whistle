var _seurimas$whistle$Native_Impl = function () {
  var nativeBinding = _elm_lang$core$Native_Scheduler.nativeBinding;
  var succeed = _elm_lang$core$Native_Scheduler.succeed;
  var receive = _elm_lang$core$Native_Scheduler.receive;
  var fail = _elm_lang$core$Native_Scheduler.fail;
  var audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  /** Rather than try to get JS WebAudio objects through Elm "customs",
  store a reference to those objects and retrieve them as needed. **/
  var audioNodes = {};
  var apiObjs = {};
  var nodeCount = 0;
  function getNewNode(node, config) {
    var nodeRef = nodeCount++;
    audioNodes[nodeRef] = {
      nodeRef: nodeRef,
      nodeType: config.nodeType,
      destination: config.destination,
      source: config.source,
    };
    apiObjs[nodeRef] = node;
    return audioNodes[nodeRef];
  }
  function nodeError(nodeObj, callback, errorString) {
    callback(fail(errorString + ": " + JSON.stringify(nodeObj)));
  }
  /** Helpers */
  function getApiNode(nodeObj) {
    return apiObjs[nodeObj.nodeRef];
  }
  /** Constructors */
  var microphoneStreamId = null;
  function getMicrophoneStream() {
    return nativeBinding(function(callback) {
      if (microphoneStreamId !== null) {
        callback(succeed(audioNodes[microphoneStreamId]));
        return;
      }
      navigator.mediaDevices.getUserMedia({ audio: true}).then(
      function(stream) {
        var microphone = audioCtx.createMediaStreamSource(stream);
        var microphoneNode = getNewNode(microphone, {
          nodeType: 'microphone',
          destination: false,
          source: true,
        })
        microphoneStreamId = microphone.nodeRef;
        callback(succeed(microphoneNode));
      }, function(err) {
        callback(fail('getUserMedia failed: ' + err));
      });
    });
  }
  /** Audio nodes */
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
      var apiNode = getApiNode(nodeObj);
      if (nodeObj.nodeType !== 'gain') {
        nodeError(nodeObj, callback, 'Not a gain node');
      }
      else if (apiNode) {
        apiNode.gain.value = newValue;
        callback(succeed(nodeObj));
      } else {
        nodeError(nodeObj, callback, 'Gain node forgotten');
      }
    });
  }
  function connect(source, destination) {
    function missingDestination(nodeObj, callback) {
      if (!nodeObj.destination) {
        nodeError(nodeObj, callback, 'Not a destination');
        return true;
      } else if (!getApiNode(nodeObj)) {
        nodeError(nodeObj, callback, 'Destination node forgotten');
        return true;
      } else {
        return false;
      }
    }
    function missingSource(nodeObj, callback) {
      if (!nodeObj.source) {
        nodeError(nodeObj, callback, 'Not a source');
        return true;
      } else if (!getApiNode(nodeObj)) {
        nodeError(nodeObj, callback, 'Source node forgotten');
        return true;
      } else {
        return false;
      }
    }
    return nativeBinding(function(callback) {
      if (!missingSource(source, callback)) {
        if (!missingDestination(destination, callback)) {
          getApiNode(source).connect(getApiNode(destination));
          callback(succeed(destination));
        }
      }
    });
  }
  var audioContextDestination = getNewNode(audioCtx.destination, {
    destination: true,
    source: false,
    type: 'context',
  });
  return {
    audioContextDestination: audioContextDestination,
    getMicrophoneStream: getMicrophoneStream(), // F0
    createOscillator: F2(createOscillator),
    createGainNode: createGainNode, // F1
    changeGain: F2(changeGain),
    connect: F2(connect),
  }
}();
