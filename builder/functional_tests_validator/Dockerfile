# This dockerfile is used to create an image that can validate the
# results of the functional tests.
FROM gcr.io/google_appengine/debian9
RUN mkdir /validator
ADD ./validator.sh /validator
WORKDIR /validator
ENTRYPOINT [ "/validator/validator.sh" ]
