export python_virtualenv=$(pyenv prefix)
export python_implementation=$(python -c "import platform; print(platform.python_implementation())")
export python_version=$(python -c "import sys; print(str(sys.version_info.major)+'.'+str(sys.version_info.minor))")

if [ $CIRCLECI ]; then
echo 'export python_virtualenv=$(pyenv prefix)' >> $BASH_ENV
echo 'export python_implementation=$(python -c "import platform; print(platform.python_implementation())")' >> $BASH_ENV
echo 'export python_version=$(python -c "import sys; print(str(sys.version_info.major)+'.'+str(sys.version_info.minor))")' >> $BASH_ENV
fi

if [ "$(uname)" == "Darwin" ]; then
  export system_os="OSX"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  export system_os="LINUX"
fi
