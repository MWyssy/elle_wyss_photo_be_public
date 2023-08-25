FROM python:3.8-slim-buster

RUN pip3 install pipenv

ENV PROJECT_DIR /usr/src/ewpapi

WORKDIR ${PROJECT_DIR}

COPY Pipfile ${PROJECT_DIR}/
COPY api.py ${PROJECT_DIR}/ 
COPY assets ${PROJECT_DIR}/assets

RUN pipenv install --deploy

EXPOSE 5000

CMD ["pipenv", "run", "python", "api.py"]