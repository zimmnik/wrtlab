FROM	 	fedora:36

COPY		bootstrap.sh run.sh /tmp/
RUN		/tmp/bootstrap.sh && rm -v /tmp/bootstrap.sh

WORKDIR		/usr/src/builder
CMD 		["/usr/src/builder/run.sh"]
