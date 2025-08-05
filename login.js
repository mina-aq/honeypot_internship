export default async function (context, commands) {
  const username = 'username';
  const password = 'password';
  const usernameField = 'user_field';
  const passwordField = 'pass_field'

  const loginURL = 'http://example.com/login';
  const URL = 'http://example.com';
  //const buttonID = 'button_ID';
  const baseDomain = 'example';
  const Depth = 2;



  const visited = new Set();

  async function crawlAndMeasure(url, depth = 0, maxDepth = 2) {
    if (visited.has(url) || depth > maxDepth) return;
    visited.add(url);

    try {
      await commands.measure.start(url);
    } catch (error) {
      console.error(`Error occured while measuring ${url} : ${error.message}`);
      return; 
    }

    const links = await commands.js.run(`
      return Array.from(document.querySelectorAll('a'))
        .map(a => a.href)
        .filter(href => href.includes('${baseDomain}') && !href.includes('#'));
    `);

    for (const href of links) {
      if (!visited.has(href)) {
        await crawlAndMeasure(href, depth + 1, maxDepth);
      }
    }
  }


  // Login
  await commands.navigate(loginURL);
  await commands.addText.byId(username, usernameField);
  await commands.addText.byId(password, passwordField);
  //await commands.click.byIdAndWait(buttonID);
  await commands.click.bySelector('button[type="submit"]');

  // Start crawl
  await crawlAndMeasure(URL, 0, Depth);
}
