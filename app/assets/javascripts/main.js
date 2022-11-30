window.onload = function() {
  // From the govuk-frontend template.njk
  document.body.className = ((document.body.className) ? document.body.className + ' js-enabled' : 'js-enabled');

  window.GOVUKFrontend.initAll()

  $("body").on('click', '.rmi-govuk-table-accordion-icon', function( event ) {
    var tableIconVal = this.getAttribute("data-table-icon");

    var tableAccContent = document.querySelector("[data-table-accordion='" + tableIconVal + "']");

    if (tableAccContent.classList.contains("rmi-table-accordion-content--expanded")) {
      tableAccContent.classList.remove("rmi-table-accordion-content--expanded");
      this.classList.remove("rmi-govuk-table-accordion-expanded")
    } else {
      tableAccContent.classList.add("rmi-table-accordion-content--expanded");
      this.classList.add("rmi-govuk-table-accordion-expanded")
    }
  })
};
