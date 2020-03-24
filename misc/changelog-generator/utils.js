
function parseMessage() {
  const message_prefix = arguments[0];
  var commitArray = arguments[1];
  const commit = arguments[2];
  
  commitArray.push(
    `* ${commit.message.substring(message_prefix)} ([${commit.sha.substring(
      0,
      6
    )}](https://github.com/Azure/azureml-sdk-for-r/commit/${
      commit.sha
    }))\n`
  );
  
  return commitArray
}

function formatUpdates() {
  var notes = arguments[0];
  const sectionHeading = arguments[1];
  const messages = arguments[2];
  
  notes += sectionHeading;
  messages.forEach(message => {
    notes += message;
  });
  notes += '\n';
  
  return notes
}

exports.parseMessage = parseMessage;
exports.formatUpdates = formatUpdates;