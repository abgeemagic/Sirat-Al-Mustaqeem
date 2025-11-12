import json
import pandas as pd
import pdfplumber
from pathlib import Path
import argparse
from typing import Dict, List, Any

def extract_advanced_pdf_content(pdf_path: str) -> Dict[str, Any]:
    """
    Advanced PDF extraction with tables, images, and metadata
    """
    result = {
        "source_file": pdf_path,
        "pages": [],
        "tables": [],
        "images": [],
        "metadata": {},
        "summary": {}
    }
    
    try:
        with pdfplumber.open(pdf_path) as pdf:
            
            if pdf.metadata:
                result["metadata"] = {
                    "title": pdf.metadata.get('Title', ''),
                    "author": pdf.metadata.get('Author', ''),
                    "subject": pdf.metadata.get('Subject', ''),
                    "creator": pdf.metadata.get('Creator', ''),
                    "producer": pdf.metadata.get('Producer', ''),
                    "creation_date": str(pdf.metadata.get('CreationDate', '')),
                    "modification_date": str(pdf.metadata.get('ModDate', ''))
                }
            
            all_text = ""
            total_tables = 0
            total_images = 0
            
            
            for page_num, page in enumerate(pdf.pages, 1):
                page_data = {
                    "page_number": page_num,
                    "text": "",
                    "tables": [],
                    "images": [],
                    "dimensions": {
                        "width": float(page.width),
                        "height": float(page.height)
                    }
                }
                
                
                page_text = page.extract_text()
                if page_text:
                    page_data["text"] = page_text.strip()
                    all_text += page_text + "\n"
                
                
                tables = page.extract_tables()
                for table_idx, table in enumerate(tables):
                    if table:
                        table_data = {
                            "table_id": f"page_{page_num}_table_{table_idx + 1}",
                            "rows": len(table),
                            "columns": len(table[0]) if table else 0,
                            "data": table
                        }
                        page_data["tables"].append(table_data)
                        result["tables"].append(table_data)
                        total_tables += 1
                
                
                if hasattr(page, 'images'):
                    for img_idx, img in enumerate(page.images):
                        img_data = {
                            "image_id": f"page_{page_num}_image_{img_idx + 1}",
                            "x0": img.get('x0', 0),
                            "y0": img.get('y0', 0),
                            "x1": img.get('x1', 0),
                            "y1": img.get('y1', 0),
                            "width": img.get('width', 0),
                            "height": img.get('height', 0)
                        }
                        page_data["images"].append(img_data)
                        result["images"].append(img_data)
                        total_images += 1
                
                result["pages"].append(page_data)
            
            
            words = all_text.split()
            result["summary"] = {
                "total_pages": len(pdf.pages),
                "total_characters": len(all_text),
                "total_words": len(words),
                "total_tables": total_tables,
                "total_images": total_images,
                "average_words_per_page": len(words) // len(pdf.pages) if pdf.pages else 0
            }
            
    except Exception as e:
        result["error"] = str(e)
        print(f"Error processing PDF: {e}")
    
    return result

def convert_tables_to_csv_format(json_data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Convert extracted tables to CSV-like format in JSON
    """
    if "tables" not in json_data:
        return json_data
    
    for table in json_data["tables"]:
        if "data" in table and table["data"]:
            
            headers = table["data"][0] if table["data"] else []
            rows = table["data"][1:] if len(table["data"]) > 1 else []
            
            
            structured_data = []
            for row in rows:
                row_dict = {}
                for i, cell in enumerate(row):
                    header = headers[i] if i < len(headers) else f"column_{i+1}"
                    row_dict[header] = cell
                structured_data.append(row_dict)
            
            table["structured_data"] = structured_data
    
    return json_data

def advanced_pdf_to_json(pdf_path: str, output_path: str = None, include_tables: bool = True):
    """
    Convert PDF to JSON with advanced features
    """
    if not Path(pdf_path).exists():
        print(f"Error: PDF file '{pdf_path}' not found!")
        return
    
    print(f"Converting '{pdf_path}' to JSON with advanced extraction...")
    
    
    json_data = extract_advanced_pdf_content(pdf_path)
    
    
    if include_tables:
        json_data = convert_tables_to_csv_format(json_data)
    
    
    if not output_path:
        pdf_name = Path(pdf_path).stem
        output_path = f"{pdf_name}_advanced.json"
    
    
    try:
        with open(output_path, 'w', encoding='utf-8') as json_file:
            json.dump(json_data, json_file, indent=2, ensure_ascii=False)
        
        print(f"✅ Successfully converted to '{output_path}'")
        
        if "summary" in json_data:
            summary = json_data["summary"]
            print(f"📊 Summary:")
            print(f"   - Pages: {summary.get('total_pages', 'N/A')}")
            print(f"   - Words: {summary.get('total_words', 'N/A')}")
            print(f"   - Tables: {summary.get('total_tables', 'N/A')}")
            print(f"   - Images: {summary.get('total_images', 'N/A')}")
        
    except Exception as e:
        print(f"❌ Error saving JSON file: {e}")

def main():
    parser = argparse.ArgumentParser(description="Advanced PDF to JSON converter")
    parser.add_argument("pdf_path", help="Path to the PDF file")
    parser.add_argument("-o", "--output", help="Output JSON file path")
    parser.add_argument("--no-tables", action="store_true", 
                       help="Skip table structure conversion")
    
    args = parser.parse_args()
    
    advanced_pdf_to_json(args.pdf_path, args.output, not args.no_tables)

if __name__ == "__main__":
    main()
