FROM public.ecr.aws/lambda/nodejs:18

# Install ClamAV and other dependencies
RUN yum -y update && \
    yum -y install clamav clamav-update && \
    yum clean all && \
    npm i -g pnpm

# Copy code
COPY package.json pnpm-lock.yaml tsconfig.json ./

RUN ls -la

# Install Node deps and build
RUN pnpm install --frozen-lockfile

# Copy the rest of the code
COPY ./handler.ts ./
RUN pnpm run build

# Update virus definitions
RUN freshclam

COPY ./handler.js ${LAMBDA_TASK_ROOT}

# Set handler
CMD [ "handler.handler" ]
