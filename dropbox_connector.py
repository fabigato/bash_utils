import argparse
from dropbox.dropbox import Dropbox
from os.path import splitext, basename, join, split
from tqdm import tqdm
from os import environ

with open(environ['DROPBOX_DEV_KEY_FILE'], "r+") as dev_key_file:
    # Reading from a file
    dev_key = dev_key_file.readline()
db_con = Dropbox(dev_key)

SCRAM_CHARS = environ['SCRAM_CHARS']
SCRAM_CHARS_REV = SCRAM_CHARS[::-1]


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-k', '--keywords', nargs='+', action="append",
                        help='<Required> list of keyword filters (space separated). A file name must include them '
                             'all to be included. This argument can be used several times, then all files that fulfill '
                             'any of the lists are included', required=True)
    parser.add_argument("-d", "--destination", help="local folder to download files. If not included, file names "
                                                    "are simply displayed")
    parser.add_argument("-b", "--base", help="base directory to search. If not provided, base port directory assumed")
    parser.add_argument("-t", "--translate", action="store_true", help="translate displayed output")
    return parser.parse_args()


def get_files_and_folders(path, connection):
    # TODO results from files_list_folder are paginated. It returns a ListFolderResult object, if its has_more property
    # is true, pass its cursor object to files_list_folder_continue to get the next page
    page_result = connection.files_list_folder(path, recursive=True)
    result = [f.path_lower for f in page_result.entries]
    while page_result.has_more:
        page_result = connection.files_list_folder_continue(page_result.cursor)
        result += [f.path_lower for f in page_result.entries]
    return result


def translate_name(file):
    return splitext(file)[0].translate(str.maketrans(SCRAM_CHARS, SCRAM_CHARS_REV)) + splitext(file)[1]


def translate_names(files):
    return [translate_name(f) for f in files]


def filter_files(files, filters):
    return [file for file in files if all([keyword in file for keyword in filters])]


def download(files, destination):
    bar = tqdm(files)
    for file in bar:
        with open(join(destination, translate_name(basename(file))), "wb") as fh:
            metadata, res = db_con.files_download(file)
            # bar.set_description("downloading {:.2f} MB file {}".format(metadata.size/1000000, translate_name(basename(file))))
            tqdm.write("downloading {:.2f} MB file {}".format(metadata.size/1000000, translate_name(basename(file))))
            fh.write(res.content)


if __name__ == "__main__":
    args = parse_args()
    base = args.base if args.base else '/misc/port'
    files = get_files_and_folders(base, db_con)
    translated = translate_names(files)
    results = []
    for filter_list in args.keywords:
        results += filter_files(translated, filter_list)
    results = list(set(results))
    if args.destination:
        download(translate_names(results), args.destination)
    else:
        if not args.translate:
            results = translate_names(results)
        for file in results:
            print(file)
    exit(0)
