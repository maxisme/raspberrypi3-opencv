FROM balenalib/raspberrypi3-debian:latest

ARG opencv_version=4.0.0

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y \
build-essential \
git \
cmake \
wget \
unzip \
yasm \
pkg-config \
libswscale-dev \
libjpeg-dev \
libpng-dev \
libtiff-dev \
libavformat-dev \
libpq-dev \
libffi-dev \
libssl-dev \
libatlas-base-dev \
gfortran \
python-mysqldb \
libraspberrypi-bin \
python3-dev \
python3-setuptools \
imagemagick \
shellcheck \
supervisor
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# install pip
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py && rm get-pip.py
RUN pip3 install numpy

# install opencv
RUN mkdir -p /tmp/opencv
RUN wget -O /tmp/opencv/opencv.zip https://github.com/opencv/opencv/archive/${opencv_version}.zip
RUN wget -O /tmp/opencv/opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/${opencv_version}.zip
WORKDIR /tmp/opencv/
RUN unzip opencv_contrib.zip
RUN unzip opencv.zip
WORKDIR /tmp/opencv/opencv-${opencv_version}/
RUN mkdir build
WORKDIR /tmp/opencv/opencv-${opencv_version}/build/
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=/tmp/opencv/opencv_contrib-${opencv_version}/modules \
    -D ENABLE_VFPV3=ON \
    -D BUILD_TESTS=OFF \
    -D ENABLE_NEON=ON \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D INSTALL_C_EXAMPLES=OFF \
    -D BUILD_EXAMPLES=OFF ..

RUN make -j8
RUN make install
RUN ldconfig
RUN rm -rf /tmp/opencv
RUN apt-get update && apt-get install -y python-opencv libffi-dev libmariadbclient-dev

RUN ln -s /usr/local/python/cv2/python-3.7/cv2.cpython-37m-arm-linux-gnueabihf.so /usr/local/lib/python3.7/dist-packages/