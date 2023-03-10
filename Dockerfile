ARG FROMIMG=riazarbi/maker_binder:20220124

FROM ${FROMIMG}

LABEL authors="Riaz Arbi"
ARG DEBIAN_FRONTEND=noninteractive

USER root
# Ensure correct place for saving R packages
ENV R_LIBS_SITE=/usr/local/lib/R/site-library
ENV R_LIBS_USER=/usr/local/lib/R/site-library

WORKDIR /
# Install system dependencies
COPY apt.txt .

RUN echo "Checking for 'apt.txt'..." \
        ; if test -f "apt.txt" ; then \
        apt-get update --fix-missing > /dev/null\
        && xargs -a apt.txt apt-get install --yes \
        && apt-get clean > /dev/null \
        && rm -rf /var/lib/apt/lists/* \
        && rm -rf /tmp/* \
        ; fi



# Install R dependencies
COPY install.R .
RUN if [ -f install.R ]; then R --quiet -f install.R; fi

# Back to non privileged user
# Make sure the contents of our repo are in ${HOME}
# These env vars are in FROM image
ENV NB_USER=maker
ENV NB_UID=1000
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}
COPY . ${HOME}
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}
WORKDIR ${HOME}
