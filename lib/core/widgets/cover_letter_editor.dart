import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

/// A rich text editor widget for cover letters.
/// Reads and writes HTML, compatible with TipTap output from the web app.
class CoverLetterEditor extends StatefulWidget {
  /// Optional initial HTML content to pre-populate the editor.
  final String? initialHtml;

  /// Called whenever the content changes, with the current HTML string.
  final ValueChanged<String>? onChanged;

  const CoverLetterEditor({
    super.key,
    this.initialHtml,
    this.onChanged,
  });

  @override
  State<CoverLetterEditor> createState() => CoverLetterEditorState();
}

class CoverLetterEditorState extends State<CoverLetterEditor> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = _controllerFromHtml(widget.initialHtml);
    _controller.addListener(_onChanged);
  }

  QuillController _controllerFromHtml(String? html) {
    if (html != null && html.trim().isNotEmpty) {
      try {
        final delta = HtmlToDelta().convert(html);
        return QuillController(
          document: Document.fromDelta(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (_) {
        // Fall back to empty controller if HTML parsing fails
      }
    }
    return QuillController.basic();
  }

  void _onChanged() {
    widget.onChanged?.call(getHtml());
  }

  /// Returns the current content as an HTML string.
  String getHtml() {
    try {
      final deltaJson = _controller.document.toDelta().toJson();
      final converter = QuillDeltaToHtmlConverter(
        List<Map<String, dynamic>>.from(deltaJson),
        ConverterOptions.forEmail(),
      );
      return converter.convert().trim();
    } catch (_) {
      return _controller.document.toPlainText().trim();
    }
  }

  /// Returns the current content as plain text (for display/validation).
  String getPlainText() => _controller.document.toPlainText().trim();

  /// Replaces the editor content with the given HTML string.
  void setHtml(String html) {
    try {
      final delta = HtmlToDelta().convert(html);
      _controller.document = Document.fromDelta(delta);
      _controller.moveCursorToEnd();
    } catch (_) {
      // If HTML parsing fails, fall back to treating as plain text
      _controller.clear();
      _controller.compose(
        Delta()..insert(html),
        const TextSelection.collapsed(offset: 0),
        ChangeSource.remote,
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toolbar
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
            border: Border.all(color: theme.dividerColor),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: QuillSimpleToolbar(
            controller: _controller,
            config: const QuillSimpleToolbarConfig(
              toolbarIconAlignment: WrapAlignment.start,
              showBoldButton: true,
              showItalicButton: true,
              showUnderLineButton: true,
              showStrikeThrough: false,
              showListBullets: true,
              showListNumbers: true,
              showListCheck: false,
              showCodeBlock: false,
              showQuote: false,
              showInlineCode: false,
              showLink: false,
              showSearchButton: false,
              showSubscript: false,
              showSuperscript: false,
              showSmallButton: false,
              showHeaderStyle: false,
              showFontFamily: false,
              showFontSize: false,
              showAlignmentButtons: false,
              showBackgroundColorButton: false,
              showColorButton: false,
              showClearFormat: true,
              showDividers: false,
              showUndo: true,
              showRedo: true,
              showClipboardCut: false,
              showClipboardCopy: false,
              showClipboardPaste: false,
              showLeftAlignment: false,
              showCenterAlignment: false,
              showRightAlignment: false,
              showJustifyAlignment: false,
              showDirection: false,
              showIndent: false,
            ),
          ),
        ),
        // Editor body
        GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: Container(
            constraints: const BoxConstraints(minHeight: 180),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Theme.of(context).dividerColor),
                right: BorderSide(color: Theme.of(context).dividerColor),
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: QuillEditor(
              controller: _controller,
              focusNode: _focusNode,
              scrollController: ScrollController(),
              config: const QuillEditorConfig(
                placeholder: 'Write your cover letter here...',
                padding: EdgeInsets.all(12),
                autoFocus: false,
                expands: false,
                scrollable: true,
                maxHeight: 320,
                minHeight: 180,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
