<?php

namespace App\Enums;

enum DoctorStatus: string
{
    case Active = 'active';
    case Inactive = 'inactive';
    case OnLeave = 'on_leave';
}
