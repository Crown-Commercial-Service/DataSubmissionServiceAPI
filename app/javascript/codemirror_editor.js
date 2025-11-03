import { EditorState } from "@codemirror/state";
import { EditorView, keymap, lineNumbers } from "@codemirror/view";
import { defaultKeymap } from "@codemirror/commands";
import { oneDark } from "@codemirror/theme-one-dark";

export function initializeCodeMirror(textAreaId) {
    const textArea = document.getElementById('code-editor');
    if (!textArea) return;

    const extensions = [
        lineNumbers(),
        keymap.of(defaultKeymap),
        oneDark,
    ];

    if (textArea.hasAttribute('readonly')) {
        extensions.push(EditorView.editable.of(false));
    }

    const state = EditorState.create({
        doc: textArea.value,
        extensions: extensions
    });

    const view = new EditorView({
        state,
        parent: textArea.parentNode
    });

    if (textArea.className) view.dom.className += ` ${textArea.className}`;

    // Hide the original textarea and update the value before form submission
    textArea.style.display = 'none';
    textArea.form?.addEventListener("submit", () => {
        textArea.value = view.state.doc.toString();
    });
}
