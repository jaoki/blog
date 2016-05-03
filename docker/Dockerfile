FROM centos:centos7

RUN yum -y install vim wget tar
RUN wget https://github.com/spf13/hugo/releases/download/v0.14/hugo_0.14_linux_386.tar.gz
RUN tar -xvf hugo_0.14_linux_386.tar.gz
RUN cd /usr/local/bin/ && ln -s /hugo_0.14_linux_386/hugo_0.14_linux_386 hugo
RUN yum -y install curl net-tools

