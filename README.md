Misc (mostly bash) scripts for different file management tasks
# Building
## python
from the respective python project folder, run
```commandline
poetry build
```
this will create a whl file. You can then install it with pip:
```commandline
python3.10 -m pip install --force-reinstall dropbox_browse-0.1.0-py3-none-any.whl
```

## shell
run the build_deb.sh script. Then run
```commandline
dpkg -i bashutils.deb
```

# Run
## python
### dropbox_connector
```commandline
 python3.10 -m dropbox_connector 
```
## shell
just call the respective command from a terminal

# Testing
the shell scripts uses [shunit2](https://github.com/kward/shunit2?tab=readme-ov-file) 
you can simply download the shunit2.sh file and put it in your PATH, but there's a convenient deb package for ubuntu:
```
sudo apt-get install -y shunit2
```
