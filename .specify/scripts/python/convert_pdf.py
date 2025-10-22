#!/usr/bin/env python3
"""Convert PDF to Markdown format for TeacherKit

Extracts text from PDF and formats as Markdown with chapter detection.
"""

import sys
import re
from pathlib import Path
from typing import List, Tuple

try:
    import fitz  # PyMuPDF
except ImportError:
    print("Error: PyMuPDF not installed. Run: pip install pymupdf")
    sys.exit(1)


def extract_text_from_pdf(pdf_path: str) -> str:
    """Extract all text from PDF"""
    try:
        doc = fitz.open(pdf_path)
        text = ""
        
        # Iterate through pages (doc is iterable)
        for page in doc:  # type: ignore
            page_text = page.get_text()
            text += f"\n{page_text}\n"
        
        doc.close()
        return text
    except Exception as e:
        print(f"Error reading PDF: {e}")
        sys.exit(1)


def detect_chapters(text: str) -> List[Tuple[str, int]]:
    """Detect chapter headings in text
    
    Returns list of (heading_text, level) tuples
    """
    chapters = []
    lines = text.split('\n')
    
    # Common chapter patterns (Chinese and English)
    patterns = [
        (r'^第[一二三四五六七八九十百\d]+章\s*[：:]\s*(.+)', 2),  # 第一章: Title
        (r'^第[一二三四五六七八九十百\d]+[节讲部分]\s*[：:]\s*(.+)', 3),  # 第一节: Title
        (r'^[一二三四五六七八九十][\s、\.]+(.+)', 3),  # 一、Title
        (r'^[\d]+[\s、\.]+(.+)', 3),  # 1. Title
        (r'^Chapter\s+\d+[：:]\s*(.+)', 2),  # Chapter 1: Title
        (r'^Section\s+\d+[：:]\s*(.+)', 3),  # Section 1: Title
    ]
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        for pattern, level in patterns:
            match = re.match(pattern, line, re.IGNORECASE)
            if match:
                title = match.group(1).strip() if match.groups() else line
                chapters.append((line, level))
                break
    
    return chapters


def format_as_markdown(text: str, pdf_name: str) -> str:
    """Format extracted text as Markdown with chapter structure"""
    
    # Detect chapters
    chapters = detect_chapters(text)
    
    # Build Markdown
    markdown = f"# {pdf_name}\n\n"
    
    if not chapters:
        # No chapter structure detected, just format as sections
        markdown += text.strip()
    else:
        # Process text with chapter markers
        lines = text.split('\n')
        current_section = []
        
        for line in lines:
            line_stripped = line.strip()
            
            # Check if this line is a chapter heading
            is_heading = False
            for heading_text, level in chapters:
                if line_stripped == heading_text:
                    # Output previous section
                    if current_section:
                        markdown += '\n'.join(current_section) + '\n\n'
                        current_section = []
                    
                    # Add heading
                    markdown += '#' * level + ' ' + heading_text + '\n\n'
                    is_heading = True
                    break
            
            if not is_heading and line_stripped:
                current_section.append(line_stripped)
        
        # Output final section
        if current_section:
            markdown += '\n'.join(current_section) + '\n'
    
    return markdown


def clean_text(text: str) -> str:
    """Clean up extracted text"""
    # Remove excessive whitespace
    text = re.sub(r'\n{3,}', '\n\n', text)
    
    # Fix common PDF extraction issues
    text = re.sub(r'(\w)-\n(\w)', r'\1\2', text)  # Remove hyphenation
    
    return text.strip()


def convert_pdf_to_markdown(pdf_path: str, output_path: str | None = None) -> str:
    """Main conversion function
    
    Args:
        pdf_path: Path to PDF file
        output_path: Optional output path for Markdown file
        
    Returns:
        Path to generated Markdown file
    """
    pdf_file = Path(pdf_path)
    
    if not pdf_file.exists():
        print(f"Error: PDF file not found: {pdf_path}")
        sys.exit(1)
    
    print(f"Converting PDF: {pdf_file.name}")
    
    # Extract text
    print("  [1/3] Extracting text...")
    text = extract_text_from_pdf(str(pdf_file))
    
    # Clean text
    print("  [2/3] Cleaning text...")
    text = clean_text(text)
    
    # Format as Markdown
    print("  [3/3] Formatting as Markdown...")
    pdf_name = pdf_file.stem
    markdown = format_as_markdown(text, pdf_name)
    
    # Determine output path
    if output_path:
        md_file = Path(output_path)
    else:
        md_file = pdf_file.parent / f"{pdf_name}.md"
    
    # Write output
    md_file.write_text(markdown, encoding='utf-8')
    print(f"\n✓ Markdown saved to: {md_file}")
    
    return str(md_file)


def main():
    """CLI entry point"""
    if len(sys.argv) < 2:
        print("Usage: python convert_pdf.py <pdf_file> [output_file.md]")
        print("\nExample:")
        print("  python convert_pdf.py textbook.pdf")
        print("  python convert_pdf.py textbook.pdf output.md")
        sys.exit(1)
    
    pdf_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else None
    
    convert_pdf_to_markdown(pdf_path, output_path)


if __name__ == "__main__":
    main()
