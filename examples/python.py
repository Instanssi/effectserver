#!/usr/bin/python
# -*- coding: utf-8 -*-

import socket

udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

packet = bytearray([
    1, # Speksin versio aina yksi

    1, # Tehosteen tyyppi on yksi eli valo
    0, # Ensimmäinen valo löytyy indeksistä nolla
    0, # Valon tyyppi on yksi eli RGB
    255, # Punaisuus maksimiin
    0, # Vihreys nollaan
    0, # Sinisyys nollaan

    1, # Toinen tehoste on myöskin valo eli yksi
    1, # Toinen valo on indeksissä yksi
    0, # Toisen valon tyyppi on myöskin RGB
    0, # Punaisuus nollaan
    0, # Vihreys nollaan
    255, # Sinisyys maksimiin
])


udp_socket.sendto(packet, ('localhost', 9909))

udp_socket.close()

