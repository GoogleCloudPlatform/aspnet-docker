# This dockerfile is used to create an image that can validate the
# results of the functional tests.
FROM gcr.io/google_appengine/debian8
RUN mkdir /generator
ADD ./generator.sh /generator
WORKDIR /generator
ENTRYPOINT [ "/generator/generator.sh" ]
