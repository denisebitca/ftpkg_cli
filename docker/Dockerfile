FROM ubuntu:22.10
RUN apt-get update && apt-get install -y xvfb x11-xserver-utils xdotool libgtk-3-dev netcat-openbsd curl
ENV DISPLAY=:99
CMD ["/opt/getlink"]
