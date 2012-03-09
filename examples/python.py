#!/usr/bin/python
# -*- coding: utf-8 -*-

import socket

udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

packet = bytearray([
    1, # Speksin versio aina yksi


    0, # Nick tag
    101, # e
    112, # p
    101, # e
    108, # l
    105, # i
    0, # Nick lopetus


    1, # Tehosteen tyyppi on yksi eli valo
    0, # Ensimmäinen valo löytyy indeksistä nolla
    0, # Valon tyyppi on yksi eli RGB
    255, # Punaisuus maksimiin
    0, # Vihreys nollaan
    0, # Sinisyys nollaan


    1, # Toinen tehoste on myöskin valo eli yksi
    1, # Toinen valo on indeksissä yksi
    0, # Toisen valon tyyppi on myöskin RGB
    # Ja sit rbg kuten edellä
    0,
    255,
    0,




])


udp_socket.sendto(packet, ('192.168.10.1', 9909))

udp_socket.close()

