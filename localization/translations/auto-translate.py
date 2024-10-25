import os, re, subprocess

## Install gettext before run https://mlocati.github.io/articles/gettext-iconv-windows.html

def create_template_pot_file(translation_keys: dict):
     with open(os.path.join(CURRENT_DIR, translation_template_name), 'w+', encoding="utf8") as file:
        file.write('''# GodotExtensionatorStarter - Translation template:
#
# FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.
#
#, fuzzy
msgid ""
msgstr ""
"Project-Id-Version: GodotExtensionatorStarter\\n"
"MIME-Version: 1.0\\n"
"Content-Type: text/plain; charset=UTF-8\\n"
"Content-Transfer-Encoding: 8-bit\\n"

''')
        for translation_key, filepath in translation_keys.items():
            file.write(f'\n#: {filepath}\n')
            file.write(f'msgid "{translation_key}"\nmsgstr "{translation_key}"\n')


def find_translation_keys(dirpath: str):
    if os.path.isdir(dirpath):
        for root, _, files in os.walk(dirpath, topdown=True, followlinks=False):
            for file in list(filter(included_files_filter, files)):
                filepath = os.path.join(root, file)
                scan_file_for_translation_keys(filepath)

       
def create_or_update_translation_files(selected_locales = []):
    translation_template_path = os.path.join(CURRENT_DIR, translation_template_name).lstrip().replace("\\", "/")

    for locale in selected_locales:
        current_po_translation_path = os.path.join(CURRENT_DIR, f"{locale}.po").lstrip().replace("\\", "/")
       
        if os.path.exists(current_po_translation_path):
            subprocess.run(['msgmerge', '--update', '--backup=none', current_po_translation_path, translation_template_path], check=True, capture_output=True, text=True)
        else:
            subprocess.run(['msginit', '--no-translator', f'--input={translation_template_path}', f'--locale={current_po_translation_path}'] , check=True, capture_output=True, text=True)


def included_files_filter(file: str) -> bool:
    included_extensions = [".tscn", ".tres", ".res", ".gd", ".cs"]

    split_tuple = os.path.splitext(file)
    filename = split_tuple[0]
    file_extension = split_tuple[1]

    return not "." in filename and file_extension in included_extensions


def _contains_godot_prefixes(filename: str) -> bool:
    godot_prefixes_to_exclude = ["BLEND_", "LOOP_", "PRESET_" ,"WRITE_", "SIZE_", "CULL_", "SHADOW_", "SHADING_", "ENV_", "CACHE_", "PROJECTION_", "TIMER_", "PROCESS_", "CURSOR_", "NOTIFICATION_", "SPACE_", "KEY_", "JOY_", "FREEZE_", "TRANSPARENCY_", "EASE_", "TRANS_", "MOUSE_", "TYPE_", "THREAD_", "AUTOWRAP_", "WINDOW_", "ERROR_", "ERR_", "BYTE_", "MSAA_"]

    for prefix in godot_prefixes_to_exclude:
        if filename.startswith(prefix):
            return True

    return False


def scan_file_for_translation_keys(filepath: str):
    files_readed.append(filepath)
    
    with open(filepath, 'r', encoding="utf8") as file:
        for line in file:
            for translation_key in translation_keys_from(line):
                if not _contains_godot_prefixes(translation_key):
                    translation_keys[translation_key] = os.path.relpath(filepath, GODOT_ROOT_DIR).lstrip().replace("\\", "/")


def find_godot_root_dir() -> str:
    initial_path = os.path.dirname(os.path.abspath(__file__))
    current_path = os.path.abspath(os.path.join(initial_path, os.pardir))
    root_dir = ""

    while not root_dir and os.path.isdir(current_path):
        for files in os.walk(current_path):
            for file in files:
                if "project.godot" in file:
                    root_dir = current_path
                    break

        current_path = os.path.abspath(os.path.join(current_path, os.pardir))
            
    return root_dir


def translation_keys_from(value: str):
    return re.findall(r'\b[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)+\b', value)


locales = ['en', 'es', 'fr', 'de', 'it', 'pt', 'ru']
translation_template_name = 'translations_template.pot'
files_readed = []
translation_keys = {}

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
GODOT_ROOT_DIR = find_godot_root_dir()
                              
find_translation_keys(GODOT_ROOT_DIR);
create_template_pot_file(translation_keys)
create_or_update_translation_files(locales)