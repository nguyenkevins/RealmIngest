import PyPDF2
import os

originalPath = "original-data"

def pdfToText(pdf_path):
    text = ""
    try: 
        with open(pdf_path, 'rb') as pdf_file:
            pdf_reader = PyPDF2.PdfReader(pdf_file)
            for page_num in range(len(pdf_reader.pages)):
                page = pdf_reader.pages[page_num]
                pageNoLineBreak = page.extract_text().replace('\n', '')
                text += pageNoLineBreak

    except Exception as e:
        print("Error reading PDF: ", e)
    return text

for filename in os.listdir(originalPath):
    if filename.endswith(".pdf"):
        pdf_path = os.path.join(originalPath, filename)
        text = pdfToText(pdf_path)
        with open(f"./modify-data/{filename[:-4]}.txt", "w", encoding="utf-8") as text_file:
            text_file.write(text)
    elif filename.endswith(".txt"):
        txt_path = os.path.join(originalPath, filename)
        with open(f"./original-data/{filename}", "r", encoding="utf-8") as source_file:
            with open(f"./modify-data/{filename}", "w", encoding="utf-8") as text_file:
                text_file.write(source_file.read())
print("Original Data conversion to Modified Data complete!")