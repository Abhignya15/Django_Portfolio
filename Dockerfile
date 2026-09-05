FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY Django_prep/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY Django_prep/ ./

RUN python manage.py collectstatic --noinput

EXPOSE 8000

# Start Gunicorn directly (do NOT run migrations here) so the container can start without a DB.
# Migrations will be skipped for now to allow the static site to run with SQLite or no DB.
CMD ["gunicorn", "Django_prep.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "2"]