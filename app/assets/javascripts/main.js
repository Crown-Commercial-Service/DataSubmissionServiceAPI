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
  });

  $("body").on('click', '#markdown-preview-btn', function( event ) {
    console.log("Inside previewBtn click function");
    const text = document.getElementById("notification_notification_message").value;
    console.log(text);
    console.log(JSON.stringify({ text: text }));
    fetch('/admin/notifications/preview', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content 
      },
      body: JSON.stringify({ text: text })
    })
    .then(response => {
      if(response.ok) {
        return response.json();
      }
      throw new Error('Network response was not ok.');
    })
    .then(data => {
      document.getElementById("markdown-preview").innerHTML = data.html;
    });
  });
};
