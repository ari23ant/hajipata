FROM julia:1.7.3

ENV DEBCONF_NOWARNINGS=yes

ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# dockerではapt-get推奨
RUN apt-get update && apt-get -y upgrade

# JuliaのイメージはPython3.8が入らない
RUN apt-get update && apt-get install -y \
        less \
        x11-apps \
        python3.9 \
        python3-pip \
        python3-tk

COPY ./misc/root/ /root/

RUN pip3 install --upgrade pip && pip3 install -r /root/requirements.txt
RUN julia -e 'include("/root/packages.jl")'
