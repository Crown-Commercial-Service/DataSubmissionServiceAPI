window.onload = function() {
  // From the govuk-frontend template.njk
  document.body.className = ((document.body.className) ? document.body.className + ' js-enabled' : 'js-enabled');

  window.GOVUKFrontend.initAll()
};
