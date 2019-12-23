from __future__ import absolute_import

import requests
import time
from django.db import connection

from celery4_prefork.celery import app


@app.task
def test_task_sleep(seconds=5):
    """
    A task with a long-running request to test how threads handle
    a task that is waiting for a response
    """
    time.sleep(seconds)
    return True


@app.task
def test_task_long_request(status=200, duration=5000):
    """
    A task with a long-running request to test how threads handle
    a task that is waiting for a response
    """
    requests.get(
        "https://httpstat.us/{}?sleep={}".format(status, duration),
        timeout=None,
    )


@app.task
def test_task_long_db(duration=5):
    """
    A task with a long-running request to test how threads handle
    a task that is waiting for a response
    """
    cursor = connection.cursor()

    try:
        cursor.execute("SELECT pg_sleep(%s)", duration)
    except:  # noqa: B901, E722
        # We aren't returning anything, so catch unhappy django
        pass
