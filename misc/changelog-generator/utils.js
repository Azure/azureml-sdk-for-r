
function parseMessage(message_prefix, commitArray, commit) {
/*
  Strips commit message of prefix and pushes to returned array
*/

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

function formatUpdates(notes, sectionHeading, messages) {
/*
  Format a section with a heading a corresponding commit messages
*/

  notes += sectionHeading;
  messages.forEach(message => {
    notes += message;
  });
  notes += '\n';
  
  return notes
}

exports.parseMessage = parseMessage;
exports.formatUpdates = formatUpdates;