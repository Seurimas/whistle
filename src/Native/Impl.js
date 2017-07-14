var _seurimas$whistle$Native_Impl = function () {
  var nativeBinding = _elm_lang$core$Native_Scheduler.nativeBinding;
  var succeed = _elm_lang$core$Native_Scheduler.succeed;
  var receive = _elm_lang$core$Native_Scheduler.receive;
  var fail = _elm_lang$core$Native_Scheduler.fail;
  var audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  /** Helpers */
  function getDestination(destinationId) {
    if (destinationId[0] == 'context') {
      return audioCtx.destination;
    } else if (destinationId[0] == 'stream') {
      return streams[destinationId[1]];
    } else if (destinationId[0] == 'node') {
      return audioNodes[destinationId[1]];
    }
  }
  function getSource(sourceId) {
    if (sourceId[0] == 'stream') {
      return streams[sourceId[1]];
    } else if (sourceId[0] == 'node') {
      return audioNodes[sourceId[1]];
    } else {
      return null;
    }
  }
  function getNode(nodeId) {
    if (nodeId[0] == 'node') {
      return audioNodes[nodeId[1]];
    } else {
      return null;
    }
  }
  function missingDestination(destinationId, callback) {
    if (!getDestination(destinationId)) {
      callback(fail('Missing destination ' + destinationId));
      return true;
    } else {
      return false;
    }
  }
  function missingSource(sourceId, callback) {
    if (!getSource(sourceId)) {
      callback(fail('Missing source node ' + sourceId));
      return true;
    } else {
      return false;
    }
  }
  function missingNode(audioNodeId, callback) {
    if (!getNode(audioNodeId)) {
      callback(fail('Missing audio node ' + audioNodeId));
      return true;
    } else {
      return false;
    }
  }
  /** Constructors */
  var analyzers = {};
  var analyzerCount = 0;
  function createAnalyzer() {
    return nativeBinding(function(callback) {
      var analyzerId = analyzerCount++;
      analyzers[analyzerId] = audioCtx.createAnalyzer();
      callback(succeed(analyzerId));
    });
  }
  function destroyAnalyzer(analyzerId) {
    return nativeBinding(function(callback) {
      analyzers[analyzerId].close();
      delete analyzers[analyzerId];
      callback(succeed(analyzerId));
    });
  }
  var streams = {};
  var microphoneStreamId = null;
  var streamCount = 0;
  function getMicrophoneStream() {
    return nativeBinding(function(callback) {
      if (microphoneStreamId !== null) {
        callback(succeed(['stream', microphoneStreamId]));
        return;
      }
      navigator.mediaDevices.getUserMedia({ audio: true}).then(
      function(stream) {
        microphoneStreamId = streamCount++;
        streams[microphoneStreamId] = audioCtx.createMediaStreamSource(stream);
        callback(succeed(['stream', microphoneStreamId]));
      }, function(err) {
        callback(fail('getUserMedia failed: ' + err));
      });
    });
  }
  /** Audio nodes */
  var audioNodes = {};
  var audioNodeCount = 0;
  function createOscillator(type, frequency) {
    return nativeBinding(function(callback) {
      var audioNodeId = audioNodeCount++;
      audioNodes[audioNodeId] = audioCtx.createOscillator();
      audioNodes[audioNodeId].type = type;
      audioNodes[audioNodeId].frequency.value = frequency;
      audioNodes[audioNodeId].start();
      callback(succeed(['node', audioNodeId]));
    });
  }
  function createGainNode(initialValue) {
    return nativeBinding(function(callback) {
      var audioNodeId = audioNodeCount++;
      audioNodes[audioNodeId] = audioCtx.createGain();
      audioNodes[audioNodeId].gain.value = initialValue;
      callback(succeed(['node', audioNodeId]));
    });
  }
  function changeGain(audioNodeId, newValue) {
    return nativeBinding(function(callback) {
      var audioNode = getNode(audioNodeId);
      if (!missingNode(audioNodeId, callback) && audioNode.gain) {
        audioNode.gain.value = newValue;
        callback(succeed(['node', audioNodeId]));
      } else {
        callback(fail('Node ' + audioNodeId + ' is not a gain node.'));
      }
    });
  }
  function connect(sourceId, destinationId) {
    return nativeBinding(function(callback) {
      if (!missingSource(sourceId, callback)) {
        if (!missingDestination(destinationId, callback)) {
          getSource(sourceId).connect(getDestination(destinationId));
          callback(succeed(destinationId));
        }
      }
    });
  }
  return {
    audioContextDestination: ['context', -1],
    createAnalyzer: createAnalyzer,
    destroyAnalyzer: destroyAnalyzer,
    getMicrophoneStream: getMicrophoneStream(),
    createOscillator: F2(createOscillator),
    createGainNode: createGainNode,
    changeGain: F2(changeGain),
    connect: F2(connect),
  }
}();
