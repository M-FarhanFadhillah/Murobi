<?php

namespace App\Models;

use App\Models\masjid;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class lap_keu extends Model
{
    use HasFactory;
    protected $guarded = [
        'id'
    ];
    public function masjid(){
        return $this->belongsTo(masjid::class, 'masjid_id');
    }
}
