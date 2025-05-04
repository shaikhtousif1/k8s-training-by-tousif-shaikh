# 1️⃣ Start from an official Python image as the base
FROM python:3.10-slim

# 2️⃣ Set an environment variable to prevent Python from buffering stdout/stderr (helps with logging)
ENV PYTHONUNBUFFERED=1

# 3️⃣ Set the working directory inside the container
WORKDIR /app

# 4️⃣ Copy the local requirements file into the container
COPY requirements.txt .

# 5️⃣ Install Python dependencies inside the container
RUN pip install --no-cache-dir -r requirements.txt

# 6️⃣ Copy the entire app source code into the container
COPY . .

# 7️⃣ Expose the port the app runs on
EXPOSE 5000

# 8️⃣ Define the default command to run the app
CMD ["python", "app.py"]
