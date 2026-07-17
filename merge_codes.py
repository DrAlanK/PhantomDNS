# این فایل پایتون وظیفه گرد آوردی تمام کد های داخل یک پوشه را در یک فایل با اسم مشخص دارد

import os

TARGET_DIR = "cmd/server" # اینجا مسیر پوشه ای که میخواهید کد های ان را جمع اوری کنید

OUTPUT_FILE = "merged_server_code.txt" # مشخص کردن نام فایل

def merge_go_files():

    if not os.path.exists(TARGET_DIR):
        print(f"❌ مسیر '{TARGET_DIR}' پیدا نشد! لطفاً مسیر را چک کنید.")
        return


    with open(OUTPUT_FILE, 'w', encoding='utf-8') as outfile:

        for root, _, files in os.walk(TARGET_DIR):
            for file in files:

                if file.endswith(".go"):
                    file_path = os.path.join(root, file)
                    outfile.write(f"// {'='*60}\n")
                    outfile.write(f"// 📁 File: {file_path}\n")
                    outfile.write(f"// {'='*60}\n\n")
                    try:
                        with open(file_path, 'r', encoding='utf-8') as infile:
                            outfile.write(infile.read())
                    except Exception as e:
                        outfile.write(f"// ❌ Error reading file: {e}\n")
                
                    outfile.write("\n\n\n")
                    print(f"✅ فایل اضافه شد: {file_path}")
                    
    print(f"\n🎉 کار تمام شد! تمام کدها در فایل '{OUTPUT_FILE}' ذخیره شدند.")

if __name__ == "__main__":
    print("در حال استخراج و ادغام کدها...\n")
    merge_go_files()