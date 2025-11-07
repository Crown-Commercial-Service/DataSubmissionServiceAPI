import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

import { initializeCodeMirror } from "./codemirror_editor";

import "./main";

const readyEvents = ["DOMContentLoaded", "turbo:load", "turboLinks:load"];

readyEvents.forEach((event) => {
    document.addEventListener(event, () => {

    if (window.GOVUKFrontend && typeof window.GOVUKFrontend.initAll === 'function') {
      // console.log("Initializing GOV.UK Frontend components");
      window.GOVUKFrontend.initAll();
    } else {
      // console.warn("GOV.UK Frontend is not loaded.");
    }
    
    const textArea = document.getElementById('code-editor');
    if (textArea) {
      // console.log("Initializing CodeMirror editor");
      initializeCodeMirror('code-editor');
    }
  });
});
