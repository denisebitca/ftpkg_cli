FROM debian
WORKDIR /opt
COPY ./opt/getlink .
COPY ./opt/reply .
COPY ./opt/answer .
RUN apt-get update
RUN apt-get install -y \
	xvfb \
	x11-xserver-utils \
	xdotool \
	libcanberra-gtk-module \
    	libcanberra-gtk3-module \
	netcat-openbsd \
	curl
RUN apt-get clean
ENV DISPLAY=:99
CMD ["/opt/getlink"]
