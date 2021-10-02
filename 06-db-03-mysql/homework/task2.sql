CREATE USER 'test'@'localhost'
  IDENTIFIED WITH mysql_native_password BY 'test-pass'
  PASSWORD EXPIRE INTERVAL 180 DAY
  FAILED_LOGIN_ATTEMPTS 3
  ATTRIBUTE '{"fname": "Pretty", "lname": "James"}';
ALTER USER 'test'@'localhost' WITH MAX_QUERIES_PER_HOUR 100;