FROM continuumio/miniconda3

LABEL base.image="continuumio/miniconda3"
LABEL software="flame"
LABEL software.version=" v0.0.1-dev"
LABEL description="Python scripts to build and manage QSAR models. Predictive modeling within the eTRANSAFE (http://etransafe.eu) project."
LABEL website="https://github.com/phi-grib/flame"

MAINTAINER Biel Stela <biel.stela@upf.edu>

ENV USER=phi-grib
ENV REPO=flame
ENV BRANCH=padel_request

WORKDIR /opt

RUN apt-get update &&\
    apt-get install -y libxrender-dev libgl1-mesa-dev &&\
    apt-get clean -y &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# hack to don't use cache if repo haves new commits
ADD https://api.github.com/repos/$USER/$REPO/git/refs/heads/$BRANCH version.json
RUN git clone -b $BRANCH --single-branch https://github.com/$USER/$REPO.git &&\
    cd flame && \
    conda env create -f environment.yml
    
# hand activate conda environment    
ENV PATH /opt/conda/envs/flame/bin:$PATH

WORKDIR /opt/flame/flame

RUN mv ../mols/minicaco.sdf _minicaco.sdf &&\
    python flame.py -c build -e CACO2 -f _minicaco.sdf &&\
    rm _minicaco.sdf 

EXPOSE 8080

ENTRYPOINT [ "python", "predict-ws.py" ]