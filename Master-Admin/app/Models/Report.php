<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Report extends Model
{
    protected $guarded = ['id'];

    protected $casts = [
        'status' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
