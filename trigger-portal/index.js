const { CloudBuildClient } = require('@google-cloud/cloudbuild');
const cb = new CloudBuildClient();

exports.handleTriggerRequest = async (req, res) => {
  // Enable CORS for your frontend
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(204).send('');

  const projectId = process.env.GCP_PROJECT || 'YOUR_PROJECT_ID';

  try {
    if (req.method === 'GET') {
      // Fetch all existing triggers
      const [triggers] = await cb.listBuildTriggers({ projectId });
      const simplifiedList = triggers.map(t => ({ name: t.name, id: t.id }));
      return res.status(200).json(simplifiedList);
    }

    if (req.method === 'POST') {
      // Execute the selected trigger
      const { triggerId, branchName = 'main' } = req.body;
      const [operation] = await cb.runBuildTrigger({
        projectId,
        triggerId,
        source: { branchName }
      });
      return res.status(200).send(`Build started! ID: ${operation.name}`);
    }
  } catch (err) {
    return res.status(500).send(err.toString());
  }
};
