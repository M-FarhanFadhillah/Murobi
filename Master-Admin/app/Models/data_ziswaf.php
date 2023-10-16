<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class data_ziswaf extends Model
{
    use HasFactory;
    protected $guarded = [
        'id'
    ];
    public function masjid(){
        return $this->belongsTo(masjid::class, 'masjid_id');
    }
    public function jenis_ziswaf(){
        return $this->belongsTo(jenis_ziswaf::class, 'jenis_ziswaf_id');
    }
    public function user(){
        return $this->belongsTo(User::class, 'users_id', 'id');
    }
}
