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
    const summary = document.getElementById("notification_summary").value;
    const message = document.getElementById("notification_notification_message").value;
    const previewContainer = document.getElementById('preview-container');
    const data = { summary: summary, message: message }

    fetch('/admin/notifications/preview', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content 
      },
      body: JSON.stringify(data)
    })
    .then(response => {
      if(response.ok) {
        return response.json();
      }
      throw new Error('Network response was not ok.');
    })
    .then(html => {
      previewContainer.classList.remove('govuk-visually-hidden');
      document.getElementById("summary-preview").innerHTML = html.summary;
      document.getElementById("markdown-preview").innerHTML = html.message;
    })
  });

  $("body").on('click', '#release-note-markdown-preview-btn', function( event ) {
    const header = document.getElementById("release_note_header").value;
    const body = document.getElementById("release_note_body").value;
    const previewContainer = document.getElementById('release-note-preview-container');
    const data = { header: header, body: body }

    fetch('/admin/release_notes/preview', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content 
      },
      body: JSON.stringify(data)
    })
    .then(response => {
      if(response.ok) {
        return response.json();
      }
      throw new Error('Network response was not ok.');
    })
    .then(html => {
      previewContainer.classList.remove('govuk-visually-hidden');
      document.getElementById("header-preview").innerHTML = html.header;
      document.getElementById("release-note-markdown-preview").innerHTML = html.body;
    })
  });
};
