<?php

namespace App\Http\Controllers;
use Illuminate\Http\Request;

use App\Models\banner;
use App\Models\education;
use App\Models\masjid;
use App\Http\Requests\StoremasjidRequest;
use App\Http\Requests\UpdatemasjidRequest;

class MasjidController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return view('masjid',[
            "title" => "Masjid",
            "j_masjid" => masjid::all()->count(),
            "j_edu" => education::all()->count(),
            "j_banner" => banner::where('status',true)->count()
        ]);
    }
    public function listMasjid()
    {
        
        return view('listmasjid',[
            "title" => "Masjid",
            "data" => masjid::all(),
            "listMasjid" => masjid::latest()->filter()->paginate(20)
        ]);
    }
    

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \App\Http\Requests\StoremasjidRequest  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        // dd($request->all());
        $validatedData = $request->validate([
            'masjid_name'=>'required|max:255',
            'masjid_pict' => 'required',
            'alamat' => 'required',
            'ketua_masjid' => 'required',
            'kapasitas' => 'required',
            'saldo_awal' => 'required',
            'kas' => 'required'
        ]);
        masjid::create($validatedData);
        return redirect('/listmasjid')->with('success','Masjid berhasil ditambahkan!');
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\masjid  $masjid
     * @return \Illuminate\Http\Response
     */
    public function show(masjid $masjid)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\masjid  $masjid
     * @return \Illuminate\Http\Response
     */
    public function edit(masjid $masjid)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \App\Http\Requests\UpdatemasjidRequest  $request
     * @param  \App\Models\masjid  $masjid
     * @return \Illuminate\Http\Response
     */
    public function update(UpdatemasjidRequest $request, masjid $masjid)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\masjid  $masjid
     * @return \Illuminate\Http\Response
     */
    public function destroy(masjid $masjid)
    {
        //
    }
}
