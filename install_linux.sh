#!/usr/bin/env bash

git submodule update --init --recursive

USER_ANS=0
REPO_ROOT=$(pwd)

ask_user () {
	echo "$1"
	while [[ 1 ]]; do
		printf "[${2}/${3}]: "
		read -r ANS
		if [[ "$ANS" == $2 ]]; then
			USER_ANS=1
			break
		elif [[ "$ANS" == $3 ]]; then
			USER_ANS=0
			break
		else
			USER_ANS=-1
			echo "Invalid answer."
		fi
	done
}

echo "Welcome to the Pytorch + Caffe2 installer!"
ask_user "Do you want to install it for all users?" "yes" "no"
SETUP_USER_FLAG=""
if [[ "$ANS" == "no" ]]; then
	SETUP_USER_FLAG="--user"
fi

ask_user "Do you want to enable CUDA and CUDNN support for PyTorch (CUDNN v6 or above required)?" "yes" "no"
if [[ "$ANS" == "no" ]]; then
	export CMAKE_ARGS=-DUSE_CUDA=OFF
else
	printf "Please enter the CUDNN include path: "
	read -r CUDNN_INCLUDE_DIR
	export CUDNN_INCLUDE_DIR
	printf "Please enter the CUDNN library path: "
	read -r CUDNN_LIB_DIR
	export CUDNN_LIB_DIR
	echo "What compiler use to compile the CUDA code?"
	printf "C compiler name: "
	read -r CC
	export CC
fi

cd pytorch
python2 setup.py install "$SETUP_USER_FLAG"

export CMAKE_ARGS=-DUSE_CUDA=OFF
python2 setup_caffe2.py install "$SETUP_USER_FLAG"

cd third_party/onnx/
python2 setup.py install "$SETUP_USER_FLAG"

cd third_party/pybind11/
python2 setup.py install "$SETUP_USER_FLAG"

cd "${REPO_ROOT}/vision/"
python2 setup.py install "$SETUP_USER_FLAG"
