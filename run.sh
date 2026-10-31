#!/bin/bash
PORT="${PORT:-80}"
sed -i "s/80/$PORT/g" /etc/apache2/ports.conf /etc/apache2/sites-available/*.conf
exec apache2-foreground
