import Rails from "@rails/ujs"
Rails.start()

import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

import "jquery"

import { initializeCodeMirror } from "./codemirror_editor";

import "./main";

const readyEvents = ["DOMContentLoaded", "turbo:load", "turboLinks:load"];

readyEvents.forEach((event) => {
    document.addEventListener(event, () => {
    const textArea = document.getElementById('code-editor');
    if (textArea) {
      console.log("Initializing CodeMirror editor");
      initializeCodeMirror('code-editor');
    }
  });
});
