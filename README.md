# Redis App

Welcome to Redis App! This Phoenix application integrates with Redis to add, delete, and manage data seamlessly. Follow the instructions below to set up and start the server.

## Demo Video

To see how the app works, check out this demo video:

https://github.com/user-attachments/assets/6f7e5e15-143b-424f-ae40-1fdf4a7d0110

## Prerequisites
Before starting, ensure you have the following installed on your system:

- Elixir/Erlang/NodeJS

- Docker and Docker Compose

## Getting Started

### Step 1: Clone the Repository

Clone the repository to your local machine:


```git clone https://github.com/potrap/redis_application```

### Step 2: Navigate to the Project Directory

Move into the project folder:

```сd redis_application/```

### Step 3: Install Dependencies

Fetch all required dependencies:

```mix deps.get```

### Step 4: Start Redis with Docker

Run the following command to start a Redis container using Docker Compose:

```docker-compose up -d```

### Step 5: Start the Phoenix Server

Run the Phoenix server:

```mix phx.server```