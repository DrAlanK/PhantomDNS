import os

# مسیر پوشه‌ای که می‌خواهی کدهایش استخراج شود
# با توجه به ساختار پروژه‌ات، مسیر dnsparser در پوشه internal است
TARGET_DIR = "cmd/server" 

# نام فایلی که در نهایت تمام کدها در آن ذخیره می‌شوند
OUTPUT_FILE = "merged_server_code.txt"

def merge_go_files():
    # بررسی وجود پوشه
    if not os.path.exists(TARGET_DIR):
        print(f"❌ مسیر '{TARGET_DIR}' پیدا نشد! لطفاً مسیر را چک کنید.")
        return

    # باز کردن فایل خروجی برای نوشتن
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as outfile:
        # جستجو در تمام فایل‌ها و زیرپوشه‌های مسیر مشخص شده
        for root, _, files in os.walk(TARGET_DIR):
            for file in files:
                # فقط فایل‌های گو را می‌خواهیم
                if file.endswith(".go"):
                    file_path = os.path.join(root, file)
                    
                    # ایجاد یک هدر خوانا برای مشخص کردن نام فایل
                    outfile.write(f"// {'='*60}\n")
                    outfile.write(f"// 📁 File: {file_path}\n")
                    outfile.write(f"// {'='*60}\n\n")
                    
                    # خواندن محتوای فایل و اضافه کردن به خروجی
                    try:
                        with open(file_path, 'r', encoding='utf-8') as infile:
                            outfile.write(infile.read())
                    except Exception as e:
                        outfile.write(f"// ❌ Error reading file: {e}\n")
                    
                    # چند خط فاصله بین فایل‌ها
                    outfile.write("\n\n\n")
                    print(f"✅ فایل اضافه شد: {file_path}")
                    
    print(f"\n🎉 کار تمام شد! تمام کدها در فایل '{OUTPUT_FILE}' ذخیره شدند.")

if __name__ == "__main__":
    print("در حال استخراج و ادغام کدها...\n")
    merge_go_files()